<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Server-Side Rendering
    |--------------------------------------------------------------------------
    |
    | These options configures if and how Inertia uses Server-Side Rendering
    | to pre-render the initial visits made to your application's pages.
    |
    */

    'ssr' => [
        'enabled' => false,  // Mude para false por enquanto
        'url' => 'http://ssr:13714',
    ],

    /*
    |--------------------------------------------------------------------------
    | Testing
    |--------------------------------------------------------------------------
    |
    | The values described here are used to locate Inertia components on the
    | filesystem. For more information, view the Testing chapter of the
    | Inertia documentation.
    |
    */

    'testing' => [
        'ensure_pages_exist' => false,
        'page_paths' => [
            resource_path('js/Pages'),
        ],
    ],
];
