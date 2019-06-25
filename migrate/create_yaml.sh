#!/bin/bash

# Get arguments

target_dir=$1

if [ -z "$target_dir" ]
then
  exit 999
fi

buildpack_name=$3

if [ -z "$buildpack_name" ]
then
  exit 999
fi

# Copy Deployment YAML File templates

chmod -R u+wx ${target_dir}

deploy_oc=${target_dir}/deploy-openshift/deploy-template.yaml
deploy_kube=${target_dir}/deploy-kube/deploy-kube.yaml

mkdir ${target_dir}/deploy-openshift

if [[ $? -gt 0 ]]; then
  echo "OpenShift Yaml file directory creation failed"
  exit 50
fi

mkdir ${target_dir}/deploy-kube

if [[ $? -gt 0 ]]; then
  echo "Kube Yaml file directory creation failed"
  exit 50
fi

# Substitute Application Name Values in Deployment YAML Files

# OpenShift

sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" deploy-template.yaml > ${deploy_oc}

# Kubernetes

sed -e "s/\${APP_NAME}/${app_name}/g" -e "s/\${APP_ARTIFACT_ID}/${app_name}/g" -e "s/\${TAG}/latest/g" deploy-kube.yaml > ${deploy_kube}

# Deal with Ports for different Buildpacks

case ${buildpack_name} in
  *liberty*)
  # Nothing to change
  ;;
  *java*)
  sed -e "s/9080/8080/g" ${deploy_oc}
  sed -e "s/9080/8080/g" ${deploy_kube}
  ;;
  *node*)
  sed -e "s/9080/8000/g" ${deploy_oc}
  sed -e "s/9080/8000/g" ${deploy_kube}
  ;;
  *) echo "Unsupported Buildpack: "${buildpack_name}; exit 1;;
esac;

exit 0
