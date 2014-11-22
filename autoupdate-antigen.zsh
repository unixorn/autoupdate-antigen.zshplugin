# Copyright 2014 Joe Block <jpb@unixorn.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$ANTIGEN_PLUGIN_UPDATE_DAYS" ]; then
  ANTIGEN_PLUGIN_UPDATE_DAYS=7
fi

if [ -z "$ANTIGEN_SYSTEM_UPDATE_DAYS" ]; then
  ANTIGEN_SYSTEM_UPDATE_DAYS=7
fi

if [ -z "$ANTIGEN_SYSTEM_RECEIPT_F" ]; then
  ANTIGEN_SYSTEM_RECEIPT_F='.antigen_system_lastupdate'
fi

if [ -z "$ANTIGEN_PLUGIN_RECEIPT_F" ]; then
  ANTIGEN_PLUGIN_RECEIPT_F='.antigen_plugin_lastupdate'
fi

function check_interval() {
  now=$(date +%s)
  if [ -f ~/${1} ]; then
    last_update=$(cat ~/${1})
  else
    last_update=0
  fi
  interval=$(expr ${now} - ${last_update})
  echo ${interval}
}

day_seconds=$(expr 24 \* 60 \* 60)
system_seconds=$(expr ${day_seconds} \* ${ANTIGEN_SYSTEM_UPDATE_DAYS})
plugins_seconds=$(expr ${day_seconds} \* ${ANTIGEN_PLUGIN_UPDATE_DAYS})

last_plugin=$(check_interval ${ANTIGEN_PLUGIN_RECEIPT_F})
last_system=$(check_interval ${ANTIGEN_SYSTEM_RECEIPT_F})

if [ ${last_plugin} -gt ${plugins_seconds} ]; then
  if [ ! -z "$ANTIGEN_AUTOUPDATE_VERBOSE" ]; then
    echo "It has been $(expr ${last_plugin} / $day_seconds) days since your antigen plugins were updated"
    echo "Updating plugins"
  fi
  antigen update
  $(date +%s > ~/${ANTIGEN_PLUGIN_RECEIPT_F})
fi

if [ ${last_system} -gt ${system_seconds} ]; then
  if [ ! -z "$ANTIGEN_AUTOUPDATE_VERBOSE" ]; then
    echo "It has been $(expr ${last_plugin} / $day_seconds) days since your antigen was updated"
    echo "Updating antigen..."
  fi
  antigen selfupdate
  $(date +%s > ~/${ANTIGEN_SYSTEM_RECEIPT_F})
fi

# clean up after ourselves
unset ANTIGEN_PLUGIN_RECEIPT_F
unset ANTIGEN_PLUGIN_UPDATE_DAYS
unset ANTIGEN_SYSTEM_RECEIPT_F
unset ANTIGEN_SYSTEM_UPDATE_DAYS
unset day_seconds
unset last_plugin
unset last_system
unset plugins_seconds
unset system_seconds

unset -f check_interval
