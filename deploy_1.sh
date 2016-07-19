#!/bin/bash -e

function usage {
    echo "Usage: $0 <staging|production>"
    echo
    echo 'You must have the heroku utility installed and have push access on'
    echo 'Heroku.'
    echo
    echo 'HINT: Only Jenkins is allowed to deploy...'
}


THIS_SCRIPT=$(readlink -f $0)
THIS_DIR=$(dirname ${THIS_SCRIPT})

ENVIRONMENT=$1

STAGING_APP='test-boot-fil-project-staging'
PRODUCTION_APP='test-fil-project'


function check_command_line {

    if [ "${ENVIRONMENT}" = "" ] ; then
        usage
        exit 1
    fi
}

function enable_shell_echo {
    set -x
}

function get_heroku_app_name {
    case "${ENVIRONMENT}" in
        'staging' )
            HEROKU_APP=${STAGING_APP} ;;
        'production' )
            HEROKU_APP=${PRODUCTION_APP} ;;
    esac

    if [ "${HEROKU_APP}" = "" ]; then
        echo 'You must specify one of staging/production'
        exit 1
    fi
	
	heroku create ${HEROKU_APP}
	echo 'heroku app created with name :'${HEROKU_APP}
	
	heroku addons:create heroku-postgresql:hobby-dev --app ${HEROKU_APP}
	echo 'addon added for database - heroku-postgressql ... done!'
	
	
	git init
	git remote show
	#heroku git:remote -a ${HEROKU_APP} 
	
	echo 'going to execute db scripts...'
    heroku pg:psql --app ${HEROKU_APP} < C:\\Work\\Workspace\\mymobileapp1\\dbscript.sql
}

function enable_maintenance_mode {
    heroku maintenance:on --app ${HEROKU_APP}
}

function disable_maintenance_mode {
    heroku maintenance:off --app ${HEROKU_APP}
}

function deploy_code_to_heroku {
  mvn heroku:deploy-war    
}

check_command_line
enable_shell_echo
get_heroku_app_name
enable_maintenance_mode

disable_maintenance_mode
deploy_code_to_heroku