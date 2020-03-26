<project>
  <actions/>
  <description>Generated at @ESCAPE(now_str) from template '@ESCAPE(template_name)'</description>
  <keepDependencies>false</keepDependencies>
  <properties>
@(SNIPPET(
    'property_log-rotator',
    days_to_keep=365 * 3,
    num_to_keep=1000,
))@
@(SNIPPET(
    'property_job-priority',
    priority=20,
))@
@(SNIPPET(
    'property_requeue-job',
))@
@(SNIPPET(
    'property_parameters-definition',
    parameters=[
        {
            'type': 'string',
            'name': 'REMOTE_SOURCE_EXPRESSION',
            'default': '^ros-bootstrap-([^-]*-[^-]*-[^-]*(-debug)?)$',
            'description': 'Expression to match pulp remote repositories',
        },
        {
            'type': 'string',
            'name': 'DISTRIBUTION_DEST_EXPRESSION',
            'default': '^ros-(building|testing|main)-\\1$',
            'description': 'Expression to transform source remote to destination pulp distribution',
        },
        {
            'type': 'boolean',
            'name': 'EXECUTE_IMPORT',
            'description': 'If this is not true, it will only do a dry run and print the expect import, but not execute.',
            'default_value': 'false',
        },
    ],
))@
  </properties>
@(SNIPPET(
    'scm_git',
    url=ros_buildfarm_repository.url,
    branch_name=ros_buildfarm_repository.version or 'master',
    relative_target_dir='ros_buildfarm',
    refspec=None,
))@
  <scmCheckoutRetryCount>2</scmCheckoutRetryCount>
  <assignedNode>building_repository</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
@(SNIPPET(
    'builder_shell',
    script='\n'.join([
        'echo "# BEGIN SECTION: mirror repositories to pulp"',
        'if [ "$EXECUTE_IMPORT" != "true" ]; then DRY_RUN_ARG="--dry-run"; fi',
        'export PYTHONPATH=$WORKSPACE/ros_buildfarm:$PYTHONPATH',
        'python3 -u $WORKSPACE/ros_buildfarm/scripts/release/rpm/mirror_repo.py' +
        ' --pulp-base-url http://repo:24817' +
        ' --remote-source-expression "$REMOTE_SOURCE_EXPRESSION"' +
        ' --distribution-dest-expression "^\\1$"' +
        ' $DRY_RUN_ARG',
        'echo "# END SECTION"',
        '',
        'echo "# BEGIN SECTION: sync packages from mirrors to repos"',
        'if [ "$EXECUTE_IMPORT" != "true" ]; then DRY_RUN_ARG="--dry-run"; fi',
        'export PYTHONPATH=$WORKSPACE/ros_buildfarm:$PYTHONPATH',
        'python3 -u $WORKSPACE/ros_buildfarm/scripts/release/rpm/sync_repo.py' +
        ' --pulp-base-url http://repo:24817' +
        ' --distribution-source-expression $REMOTE_SOURCE_EXPRESSION' +
        ' --distribution-dest-expression $DISTRIBUTION_DEST_EXPRESSION',
        ' $DRY_RUN_ARG',
        'echo "# END SECTION"',
    ]),
))@
  </builders>
  <publishers>
@(SNIPPET(
    'publisher_mailer',
    recipients=recipients,
    dynamic_recipients=[],
    send_to_individuals=False,
))@
  </publishers>
  <buildWrappers>
@(SNIPPET(
    'credentials_binding_plugin',
    credential_id=credential_id,
    env_var_prefix='PULP',
))@
@(SNIPPET(
    'build-wrapper_timestamper',
))@
  </buildWrappers>
</project>