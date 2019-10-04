<?php

if (!\file_exists('db.json')) {
    $db = [
        'seqno' => 1,
        'minSig' => 3,
        'keys' => [
            'key1'
        ],
        'messages' => [
            'hash' => [
                'expires' => 100,
                'signatures' => [
                    0 => 'sig' // Generated from key1
                ],
                'body' => 'body'
            ]
        ]
    ];
} else {
    $db = \json_decode(\file_get_contents('db.json'), true);
}

function storeDb(array $db)
{
    \file_put_contents('db.json', \json_encode($db));
}

function garbageCollect(array $db): array
{
    $changed = false;
    foreach ($db['messages'] as $hash => $message) {
        if ($message['expires'] < \time()) {
            unset($db['messages'][$hash]);
            $changed = true;
        }
    }
    return [$changed, $db];
}

function hasKey(string $key, array $db)
{
    foreach ($db['keys'] as $id => $curKey) {
        if ($curKey === $key) {
            return $id;
        }
    }
    return false;
}


$message = \json_decode(\file_get_contents('php://input'));

$op = $message['op'];
$body = $message['body'];
if ($op === 11) {
    return $db['seqno'];
}

if ($op === 12) {
    return hasKey($body, $db);
}

if ($op === 0) {
    //list($shouldUpdate, $db) = garbageCollect($db);

    $signatures = $body['signatures'];
    if (empty($signatures)) {
        //if ($shouldUpdate) {
        //    storeDb($db);
        //}
        return 'not enough signatures';
    }

    if ($body['expires'] < \time()) {
        //if ($shouldUpdate) {
        //    storeDb($db);
        //}
        return 'message expired';
    }
    $hash = \hash('sha256', \json_encode($body));

    if ($db['seqno'] === $body['seqno']) {
        $db['seqno']++;
        $oldSignatures = [];
    // Assuming there are no signatures stored
    } elseif (!isset($db['messages'][$hash])) {
        return 'wrong seqno or no such message';
    } else {
        $oldSignatures = $db['messages'][$hash]['signatures'];
    }

    foreach ($signatures as $idx => $signature) {
        $key = $db['keys'][$idx];
        if (!checkSig($signature, $key)) {
            return 'wrong sig';
        }

        $oldSignatures[$idx] = $signature;
    }

    $count = 0;
    foreach ($oldSignatures as $sig) {
        if (++$count >= 3) {
            sendMessage($body);
            break;
        }
    }

    if ($count < 3) {
        $db['messages'][$hash] = [
            'expires' => $body['expires'],
            'signatures' => $oldSignatures,
            'body' => $body
        ];
    }
    
    storeDb(garbageCollect($db));
}