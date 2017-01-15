<?php
$backends['imap']['disabled'] = true;
$backends['sieve'] = array(
    'disabled' => false,
    'transport' => array(
        Ingo::RULE_ALL => array(
            'driver' => 'timsieved',
            'params' => array(
                'hostspec' => 'localhost',
                'logintype' => 'PLAIN',
                'usetls' => true,
                'port' => 4190,
                'scriptname' => 'ingo',
                'debug' => true
            ),
       ),
    ),
    'hordeauth' => 'full',
    'script' => array(
        Ingo::RULE_ALL => array(
            'driver' => 'sieve',
            'params' => array(
                'utf8' => true,
            ),
       ),
    ),
    'shares' => false
);
