<?php

/**
 * @file Drush PM drupal.org Git extension.
 */

/**
 * Validate this package handler can run.
 */
function package_handler_validate() {
  // Check git command exists. Disable possible output.
  $debug = drush_get_context('DRUSH_DEBUG');
  drush_set_context('DRUSH_DEBUG', FALSE);

  // We need to check for a git executable and then make sure version is >=1.7
  // (avoid drush_shell_exec because we want to run this even in --simulated mode.)
  $success = exec('git --version', $git);
  $git_version_array = explode(" ", $git[0]);
  $git_version = $git_version_array[2];

  drush_set_context('DRUSH_DEBUG', $debug);
  if (!$success) {
    return drush_set_error('DRUSH_SHELL_COMMAND_NOT_FOUND', dt('git executable not found.'));
  } elseif ($git_version < '1.7') {
    return drush_set_error('GIT_VERSION_UNSUPPORTED', dt('Your git version !git_version is not supported; please upgrade to git 1.7 or later.', array('!git_version' => $git_version)));
  }
  // Check git_deploy is enabled. Only for bootstrapped sites.
  if (drush_get_context('DRUSH_BOOTSTRAP_PHASE') >= DRUSH_BOOTSTRAP_DRUPAL_FULL) {
    if (!module_exists('git_deploy')) {
      drush_log(dt('git package handler needs git_deploy module enabled to work properly.'), 'warning');
    }
  }

  return TRUE;
}

/**
 * Download a project.
 *
 * @param $request
 *   The project array with name, base and full (final) paths.
 * @param $release
 *   The release details array from drupal.org.
 */
function package_handler_download_project(&$request, $release) {
  if ($username = drush_get_option('gitusername')) {
    // Uses SSH, which enables pushing changes back to git.drupal.org.
    $repository = $username . '@git.drupal.org:project/' . $request['name'] . '.git';
  }
  else {
    $repository = 'git://git.drupal.org/project/' . $request['name'] . '.git';
  }
  $request['repository'] = $repository;
  $tag = $release['tag'];

  // If the --cache option was given, create a new git reference cache of the
  // remote repository, or update the existing cache to fetch recent changes.
  if (drush_get_option('cache') && ($cachedir = drush_directory_cache())) {
    $gitcache = $cachedir . '/git';
    $projectcache = $gitcache . '/' . $request['name'] . '.git';
    drush_mkdir($gitcache);
    // Setup a new cache, if we don't have this project yet.
    if (!file_exists($projectcache)) {
      // --mirror works similar to --bare, but retrieves all tags, local
      // branches, remote branches, and any other refs (notes, stashes, etc).
      // @see http://stackoverflow.com/questions/3959924
      $command = 'git clone --mirror';
      if (drush_get_context('DRUSH_VERBOSE')) {
        $command .= ' --verbose --progress';
      }
      $command .= ' %s %s';
      drush_shell_cd_and_exec($gitcache, $command, $repository, $request['name'] . '.git');
    }
    // If we already have this project, update it to speed up subsequent clones.
    else {
      // A --mirror clone is fully synchronized with `git remote update` instead
      // of `git fetch --all`.
      // @see http://stackoverflow.com/questions/6150188
      drush_shell_cd_and_exec($projectcache, 'git remote update');
    }
    $gitcache = $projectcache;
  }

  // Clone the repo into its appropriate target location.
  $command  = 'git clone';
  $command .= ' ' . drush_get_option('gitcloneparams');
  if (drush_get_option('cache')) {
    $command .= ' --reference ' . drush_escapeshellarg($gitcache);
  }
  if (drush_get_context('DRUSH_VERBOSE')) {
    $command .= ' --verbose --progress';
  }
  $command .= ' ' . drush_escapeshellarg($repository);
  $command .= ' ' . drush_escapeshellarg($request['full_project_path']);
  if (!drush_shell_exec($command)) {
    return drush_set_error('DRUSH_PM_GIT_CHECKOUT_PROBLEMS', dt('Unable to clone project !name from git.drupal.org.', array('!name' => $request['name'])));
  }

  // Check if the 'tag' from the release feed is a tag or a branch.
  // If the tag exists, git will return it
  if (!drush_shell_cd_and_exec($request['full_project_path'], 'git tag -l ' . drush_escapeshellarg($tag))) {
    return drush_set_error('DRUSH_PM_GIT_CHECKOUT_PROBLEMS', dt('Unable to clone project !name from git.drupal.org.', array('!name' => $request['name'])));
  }
  $output = drush_shell_exec_output();

  if (isset($output[0]) && ($output[0] == $tag)) {
    // If we want a tag, simply checkout it. The checkout will end up in
    // "detached head" state.
    $command  = 'git checkout ' . drush_get_option('gitcheckoutparams');
    $command .= ' ' . drush_escapeshellarg($tag);
    if (!drush_shell_cd_and_exec($request['full_project_path'], $command)) {
      return drush_set_error('DRUSH_PM_UNABLE_CHECKOUT', 'Unable to retrieve ' . $request['name'] . ' from git.drupal.org.');
    }
  }
  else {
    // Else, we want to checkout a branch.
    // First check if we are not already in the correct branch.
    if (!drush_shell_cd_and_exec($request['full_project_path'], 'git symbolic-ref HEAD')) {
      return drush_set_error('DRUSH_PM_UNABLE_CHECKOUT', 'Unable to retrieve ' . $request['name'] . ' from git.drupal.org.');
    }
    $output = drush_shell_exec_output();
    $current_branch = preg_replace('@^refs/heads/@', '', $output[0]);

    // If we are not on the correct branch already, switch to the correct one.
    if ($current_branch != $tag) {
      $command  = 'git checkout';
      $command .= ' ' . drush_get_option('gitcheckoutparams');
      $command .= ' --track ' . drush_escapeshellarg('origin/' . $tag) . ' -b ' . drush_escapeshellarg($tag);
      if (!drush_shell_cd_and_exec($request['full_project_path'], $command)) {
        return drush_set_error('DRUSH_PM_UNABLE_CHECKOUT', 'Unable to retrieve ' . $request['name'] . ' from git.drupal.org.');
      }
    }
  }

  return TRUE;
}

/**
 * Update a project (so far, only modules are supported).
 *
 * @param $request
 *   The project array with name, base and full (final) paths.
 * @param $release
 *   The release details array from drupal.org.
 */
function package_handler_update_project($request, $release) {
  drush_log('Updating project ' . $request['name'] . ' ...');

  $commands = array();
  if ($release['version_extra'] == 'dev') {
    // Update the branch of the development repository.
    $commands[] = 'git pull';
    $commands[] = drush_get_option('gitpullparams');
  }
  else {
    // Use a stable repository.
    $commands[] = 'git fetch';
    $commands[] = drush_get_option('gitfetchparams');
    $commands[] = ';';
    $commands[] = 'git checkout';
    $commands[] = drush_get_option('gitcheckoutparams');
    $commands[] = $release['version'];
  }

  if (!drush_shell_cd_and_exec($request['full_project_path'], implode(' ', $commands))) {
    return drush_set_error('DRUSH_PM_UNABLE_CHECKOUT', 'Unable to update ' . $request['name'] . ' from git.drupal.org.');
  }

  return TRUE;
}

/**
 * Post download action.
 *
 * This action take place once the project is placed in its final location.
 *
 * Here we add the project as a git submodule.
 */
function package_handler_post_download($project, $release) {
  if (drush_get_option('gitsubmodule', FALSE)) {
    // Obtain the superproject path, then add as submodule.
    if (drush_shell_cd_and_exec(dirname($project['full_project_path']), 'git rev-parse --show-toplevel')) {
      $output = drush_shell_exec_output();
      $superproject = $output[0];
      // Add the downloaded project as a submodule of its git superproject.
      $command = array();
      $command[] = 'git submodule add';
      $command[] = drush_get_option('gitsubmoduleaddparams');
      $command[] = $project['repository'];
      // We need the submodule relative path.
      $command[] = substr($project['full_project_path'], strlen($superproject) + 1);
      if (!drush_shell_cd_and_exec($superproject, implode(' ', $command))) {
        return drush_set_error('DRUSH_PM_GIT_CHECKOUT_PROBLEMS', dt('Unable to add !name as a git submodule of !super.', array('!name' => $project['name'], '!super' => $superproject)));
      }
    }
    else {
      return drush_set_error('DRUSH_PM_GIT_SUBMODULE_PROBLEMS', dt('Unable to create !project as a git submodule: !dir is not in a Git repository.', array('!project' => $project['name'], '!dir' => dirname($project['full_project_path']))));
    }
  }

  if (drush_get_option('gitinfofile', FALSE)) {
    package_handler_inject_info($project, $release);
  }

}

function package_handler_inject_info($project, $release) {
  // Handler for the directory and open directory and walk through the filenames
  $info_files = drush_scan_directory($project['project_install_location'], "/.*\.info$/");
  $return = TRUE;
  // Consider that the d.o. package manager is aware of submodules in parent modules
  foreach($info_files as $info_file) {
    $return = $return && package_handler_fix_info_file_version($info_file->filename, $project['name'], $release['version']);
  }
  return $return;
}

/**
 * Fix the given .info file with the specified version string
 * Taken straight from: http://drupalcode.org/project/drupalorg.git/blob/refs/heads/6.x-3.x:/drupalorg_project/plugins/release_packager/DrupalorgProjectPackageRelease.class.php#l192
 */
function package_handler_fix_info_file_version($file, $project, $version) {
  $info = "\n\n; Information added by the drush package handler on " . date('Y-m-d') . "\n";
  $info .= "version = \"$version\"\n";
  // .info files started with 5.x, so we don't have to worry about version
  // strings like "4.7.x-1.0" in this regular expression. If we can't parse
  // the version (also from an old "HEAD" release), or the version isn't at
  // least 6.x, don't add any "core" attribute at all.
  $matches = array();
  if (preg_match('/^((\d+)\.x)-.*/', $version, $matches) && $matches[2] >= 6) {
    $info .= "core = \"$matches[1]\"\n";
  }
  $info .= "project = \"$project\"\n";
  $info .= 'datestamp = "'. time() ."\"\n";
  $info .= "\n";

  if (!$info_fd = fopen($file, 'a+')) {
    drush_set_error(dt("ERROR: fopen(@file, 'ab') failed", array('@file' => $file)));
    return false;
  }
  if (!fwrite($info_fd, $info)) {
    drush_set_error(dt("ERROR: fwrite(@file) failed", array('@file' => $file)) . '<pre>' . $info);
    return false;
  }
  return true;
}
