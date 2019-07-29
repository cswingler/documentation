#!/usr/bin/env sh

RUN_SERVER=${RUN_SERVER:=false}
FETCH_INTEGRATIONS=${FETCH_INTEGRATIONS:=false}
GITHUB_TOKEN=${GITHUB_TOKEN:="false"}
RUN_GULP=${RUN_GULP:=true}
CREATE_I18N_PLACEHOLDERS=${CREATE_I18N_PLACEHOLDERS:=false}
RENDER_SITE_TO_DISK=${RENDER_SITE_TO_DISK:=false}


if [ ${RUN_SERVER} == true ]; then

	# gulp
	if [ ${RUN_GULP} == true ]; then
		echo "checking that node modules are installed and up-to-date"
    npm --global install yarn && \
    npm cache clean --force && yarn install --frozen-lockfile
    echo "starting gulp build"
    gulp build
    sleep 5
	fi

	# integrations
	if [ ${FETCH_INTEGRATIONS} == true ]; then
		args=""
		if [ ${GITHUB_TOKEN} != "false" ]; then
			args="${args} --token ${GITHUB_TOKEN}"
		else
			echo "No GITHUB TOKEN was found. skipping any data sync that relies on pulling from web.\n"
			echo "Add all source repositories in the same parent folder as the documentation/ folder to build the full doc locally.\n"
			update_pre_build.py
		fi
		if [[ ${args} != "" ]]; then
			update_pre_build.py ${args}
		fi
	fi

	# placeholders
	if [ ${CREATE_I18N_PLACEHOLDERS} == true ]; then
		echo "creating i18n placeholder pages."
		placehold_translations.py -c "config/_default/languages.yaml"
	fi

	# hugo
	args=""
	if [ ${RENDER_SITE_TO_DISK} != "false" ]; then
		args="${args} --renderToDisk"
	fi
	# hugo server defaults to --environment development
	./node_modules/.bin/hugo server ${args} &
	sleep 5

	if [ ${RUN_GULP} == true ]; then
		echo "gulp watch..."
		gulp watch
	fi

else
	exit 0
fi
