<?php

if (!\file_exists('db.json')) {
    $db = [
        'seqno' => 1,
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

    $body = $body['body'];
    if ($body['expires'] < \time()) {
        //if ($shouldUpdate) {
        //    storeDb($db);
        //}
        return 'message expired';
    }
    $hash = \hash('sha256', \json_encode($body));

    if ($db['seqno'] === $body['seqno']) {
        $db['seqno']++;
        //$shouldUpdate = true;
    } elseif (!isset($db['messages'][$hash])) {
        //if ($shouldUpdate) {
        //    storeDb($db);
        //}
        return 'wrong seqno or no such message';
    } else {
        
    }

    $oldSignatures = $db['messages'][$hash]['signatures'] ?? [];
    $oldCount = \count($oldSignatures);

    foreach ($signatures as $idx => $signature) {
        if (isset($oldSignatures[$idx])) {
            continue;
        }

        $key = $db['keys'][$idx];
        if (!checkSig($signature, $key)) {
            continue;
        }

        $oldSignatures[$idx] = $signature;
    }

    $newCount = \count($oldSignatures);
    if ($newCount !== $oldCount) {
        $db['messages'][$hash]['signatures'] = $oldSignatures;
        $shouldUpdate = true;
    } else if (!$newCount) {
        return 'no valid signatures found!';
    }

    if ($shouldUpdate) {
        storeDb($db);
    }
    if ($newCount >= 3) {
        sendMessage($db['messages'][$hash]['body']['body']);
    }
}
