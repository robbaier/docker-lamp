<?php
$db = new PDO('mysql:host=localhost', 'root', null);

function getOSInformation()
{
    if (false == function_exists("shell_exec") || false == is_readable("/etc/os-release")) {
        return null;
    }

    $os         = shell_exec('cat /etc/os-release');
    $listIds    = preg_match_all('/.*=/', $os, $matchListIds);
    $listIds    = $matchListIds[0];

    $listVal    = preg_match_all('/=.*/', $os, $matchListVal);
    $listVal    = $matchListVal[0];

    array_walk($listIds, function(&$v, $k){
        $v = strtolower(str_replace('=', '', $v));
    });

    array_walk($listVal, function(&$v, $k){
        $v = preg_replace('/=|"/', '', $v);
    });

    return array_combine($listIds, $listVal);
}
$osInfo = getOSInformation();
?>
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>It's alive!</title>

    <style>
        @import 'https://fonts.googleapis.com/css?family=Montserrat|Raleway|Source+Code+Pro';

        body { font-family: 'Raleway', sans-serif; }
        h2 { font-family: 'Montserrat', sans-serif; }
        pre {
            font-family: 'Source Code Pro', monospace;

            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #f7f7f7;
            border-radius: 3px;

            word-wrap: normal;
        }

        .container {
            max-width: 1024px;
            width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <h2>Welcome to <a href="https://github.com/robbaier/docker-lamp" target="_blank">Docker-Lamp</a></h2>
    </header>
    <section>
            <pre>
OS: <?php echo $osInfo['pretty_name']; ?><br/>
Apache: <?php echo apache_get_version(); ?><br/>
MySQL Version: <?php echo $db->getAttribute( PDO::ATTR_SERVER_VERSION ); ?><br/>
PHP Version: <?php echo phpversion(); ?><br/>
phpMyAdmin Version: <?php echo getenv('PHPMYADMIN_VERSION'); ?>
            </pre>
    </section>
</div>
</body>
</html>