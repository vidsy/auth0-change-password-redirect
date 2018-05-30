BRANCH = "master"
REPONAME = "auth0-change-password-redirect"
VERSION = $(shell cat ./VERSION)

build-image:
	@docker build -t vidsyhq/${REPONAME} .

check-version:
	@echo "=> Checking if VERSION exists as Git tag..."
	(! git rev-list ${VERSION})

docker-hub-login:
	@echo "=> Logging into Docker Hub"
	@docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}

docker-staging-ecr-login:
	@echo "=> Logging into staging (${STAGING_REGISTRY_PREFIX}) ECR repo"
	@eval $(shell AWS_ACCESS_KEY_ID=${STAGING_AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${STAGING_AWS_SECRET_ACCESS_KEY} aws ecr get-login --no-include-email --region eu-west-1)

push-tag:
	@echo "=> New tag version: ${VERSION}"
	git checkout ${BRANCH}
	git pull origin ${BRANCH}
	git tag ${VERSION}
	git push origin ${BRANCH} --tags

push-to-ecr: docker-staging-ecr-login
	@docker tag vidsyhq/${REPONAME}:latest ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:latest
	@docker tag vidsyhq/${REPONAME}:latest ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG}
	@docker tag vidsyhq/${REPONAME}:latest ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:staging
	@echo "=> Pushing ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG} to staging"
	@docker push ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG}
	@echo "=> Pushing ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:staging to staging"
	@docker push ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:staging
	@echo "=> Pushing ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:latest to staging"
	@docker push ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:latest
	@echo "=> Deploying ${STAGING_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG} to staging"
	@AWS_ACCESS_KEY_ID=${STAGING_AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${STAGING_AWS_SECRET_ACCESS_KEY} aws ecs update-service --cluster ${ECS_CLUSTER_NAME} --service ${REPONAME} --force-new-deployment --region eu-west-1 > /dev/null
	@echo "=> Logging into live (${LIVE_REGISTRY_PREFIX}) ECR repo"
	@eval $(shell AWS_ACCESS_KEY_ID=${LIVE_AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${LIVE_AWS_SECRET_ACCESS_KEY} aws ecr get-login --no-include-email --region eu-west-1)
	@docker tag vidsyhq/${REPONAME}:latest ${LIVE_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG}
	@echo "=> Pushing ${LIVE_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG} to live"
	@docker push ${LIVE_REGISTRY_PREFIX}/vidsy/${REPONAME}:${CIRCLE_TAG}

push-to-docker-hub: docker-hub-login
	@docker tag vidsyhq/${REPONAME}:latest vidsyhq/${REPONAME}:${CIRCLE_TAG}
	@docker push vidsyhq/${REPONAME}:${CIRCLE_TAG}
	@docker push vidsyhq/${REPONAME}
