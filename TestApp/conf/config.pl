# Common settings
{
    modules      => [qw/Template::Toolkit JSON Logger/],
    modules_init => {

        # One log for errors and one for debug
        Logger => {
            outputs => [
                [
                    'File',
                    name      => 'debug',
                    filename  => 'log/debug.log',
                    min_level => 'debug',
                    mode      => '>>',
                    newline   => 1,
                    binmode   => ":encoding(UTF-8)"
                ], [
                    'File',
                    name      => 'error',
                    filename  => 'log/error.log',
                    min_level => 'error',
                    mode      => '>>',
                    newline   => 1,
                    binmode   => ":encoding(UTF-8)"
                ],
            ]
        },

        # JSON prints pretty
        JSON => {
            pretty => 1
        },

        'Template::Toolkit' => {
            ENCODING => 'utf8',
            INCLUDE_PATH => 'views',
        }
    },
    
    'models' => {
        'LittleDB' => {
            'model' => 'TestApp::Model::LittleDB',
            'args'  => ['dbi:SQLite:dbname=test.db'],
        },
    },
};
