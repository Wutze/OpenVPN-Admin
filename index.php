<?php
  session_start();

  require(dirname(__FILE__) . '/include/functions.php');
  require(dirname(__FILE__) . '/include/connect.php');

  // Disconnecting ?
  if(isset($_GET['logout'])){
    session_destroy();
    header("Location: .");
    exit(-1);
  }

  // Get the configuration files ?
  if(isset($_POST['configuration_get'], $_POST['configuration_username'], $_POST['configuration_pass'], $_POST['configuration_os'])
     && !empty($_POST['configuration_pass'])) {
    $req = $bdd->prepare('SELECT * FROM user WHERE user_id = ?');
    $req->execute(array($_POST['configuration_username']));
    $data = $req->fetch();

    // Error ?
    if($data && passEqual($_POST['configuration_pass'], $data['user_pass'])) {
      // Thanks http://stackoverflow.com/questions/4914750/how-to-zip-a-whole-folder-using-php
      if($_POST['configuration_os'] == "gnu_linux") {
        $conf_dir = 'gnu-linux';
      } elseif($_POST['configuration_os'] == "osx_viscosity") {
        $conf_dir = 'osx-viscosity';
      } else {
        $conf_dir = 'windows';
      }
      $rootPath = realpath("./../vpn/conf/$conf_dir");

      // Initialize archive object ;;;; why doing this every time the user logs in, when the cert is static?
      $archive_base_name = "openvpn-$conf_dir";
      $archive_name = "$archive_base_name.zip";
      $archive_path = "./../vpn/conf/$archive_name";
      $zip = new ZipArchive();
      $zip->open($archive_path, ZipArchive::CREATE | ZipArchive::OVERWRITE);

      $files = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($rootPath),
        RecursiveIteratorIterator::LEAVES_ONLY
      );

      foreach ($files as $name => $file) {
        // Skip directories (they would be added automatically)
        if (!$file->isDir()) {
          // Get real and relative path for current file
          $filePath = $file->getRealPath();
          $relativePath = substr($filePath, strlen($rootPath) + 1);

          // Add current file to archive
          $zip->addFile($filePath, "$archive_base_name/$relativePath");
        }
      }

      // Zip archive will be created only after closing object
      $zip->close();

      //then send the headers to foce download the zip file
      header("Content-type: application/zip");
      header("Content-Disposition: attachment; filename=$archive_name");
      header("Pragma: no-cache");
      header("Expires: 0");
      readfile($archive_path);
    }
    else {
      $error = true;
    }
  }

  // Admin login attempt ?
  else if(isset($_POST['admin_login'], $_POST['admin_username'], $_POST['admin_pass']) && !empty($_POST['admin_pass'])){

    $req = $bdd->prepare('SELECT * FROM admin WHERE admin_id = ?');
    $req->execute(array($_POST['admin_username']));
    $data = $req->fetch();

    // Error ?
    if($data && passEqual($_POST['admin_pass'], $data['admin_pass'])) {
      $_SESSION['admin_id'] = $data['admin_id'];
      header("Location: index.php?admin");
      exit(-1);
    }
    else {
      $error = true;
    }
  }
?>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />

    <title>OpenVPN-Admin</title>

    <link rel="stylesheet" href="vendor/bootstrap/dist/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="vendor/x-editable/dist/bootstrap3-editable/css/bootstrap-editable.css" type="text/css" />
    <link rel="stylesheet" href="vendor/bootstrap-table/dist/bootstrap-table.min.css" type="text/css" />
    <link rel="stylesheet" href="vendor/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css" type="text/css" />
    <link rel="stylesheet" href="vendor/bootstrap-table/dist/extensions/filter-control/bootstrap-table-filter-control.css" type="text/css" />
    <link rel="stylesheet" href="css/index.css" type="text/css" />

    <link rel="icon" type="image/png" href="css/icon.png">
  </head>
  <body class='container-fluid'>
  <?php

    // --------------- CONFIGURATION ---------------
    if(!isset($_GET['admin'])) {
      if(isset($error) && $error == true)
        printError('Login error');

      require(dirname(__FILE__) . '/include/html/menu.php');
      require(dirname(__FILE__) . '/include/html/form/configuration.php');
    }


    // --------------- LOGIN ---------------
    else if(!isset($_SESSION['admin_id'])){
      if(isset($error) && $error == true)
        printError('Login error');

      require(dirname(__FILE__) . '/include/html/menu.php');
      require(dirname(__FILE__) . '/include/html/form/login.php');
    }

    // --------------- GRIDS ---------------
    else{
  ?>
      <nav class="navbar navbar-default">
        <div class="row col-md-12">
          <div class="col-md-6">
            <p class="navbar-text signed">Signed in as <?php echo $_SESSION['admin_id']; ?>
            </div>
            <div class="col-md-6">
              <a class="navbar-text navbar-right" href="index.php?logout" title="Logout"><button class="btn btn-danger">Logout <span class="glyphicon glyphicon-off" aria-hidden="true"></span></button></a>
              <a class="navbar-text navbar-right" href="index.php" title="Configuration"><button class="btn btn-default">Configurations</button></a>
            </p>
          </div>
        </div>
      </nav>

  <?php
      require(dirname(__FILE__) . '/include/html/grids.php');
    }
  ?>
     <div id="message-stage">
        <!-- used to display application messages (failures / status-notes) to the user -->
     </div>
  </body>
</html>
