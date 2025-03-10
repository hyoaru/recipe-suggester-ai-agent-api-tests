pipeline {
  agent any

  environment {
    sanitized_branch_name = env.BRANCH_NAME.replaceAll('/', '-')

    DOCKER_NETWORK_NAME = "recipe_suggester_ai_agent_network_${env.sanitized_branch_name}_${env.BUILD_ID}"
    DOCKER_IMAGE_NAME_API_ROBOT_TEST = 'recipe_suggester_ai_agent_api_robot_test'

    API_STAGING_BASE_URL = "https://recipe-ai-api-staging.anonalyze.org"
  }

  options {
    // Required step for cleaning before build
    skipDefaultCheckout(true)
  }

  stages {
    stage('Setup and Environment Preparation') {
      stages {
        stage('Clean Workspace') {
          steps {
            script {
              echo 'Cleaning workspace...'
              cleanWs()
              echo 'Cleaned the workspace.'
            }
          }
        }

        stage('Checkout Source Code') {
          steps {
            echo 'Checking out source code...'
            checkout scm
            echo 'Checked out source code.'
          }
        }


        stage('Populate Environment Variables') {
          steps {
            script {
              writeEnvFile(".", [
                "API_BASE_URL=${env.API_STAGING_BASE_URL}"
              ])
            }
          }
        }
      }
    }

    stage('Run Tests and Quality Analysis') {
      parallel {
        stage('Run Tests') {
          stages {
            stage('Build Docker Image') {
              steps {
                echo 'Building Docker image...'
                sh 'echo "Using docker version: $(docker --version)"'

                script {
                  buildDockerImage('.', env.DOCKER_IMAGE_NAME_API_ROBOT_TEST)
                }

                sh 'docker images'
                echo 'Docker image built'
              }
            }

            stage('Run Robot Specific Tests') {
              when {
                expression { env.CHANGE_TARGET == 'develop' }
              }
              steps {
                echo 'Specific tests pending...'

                script {
                  String testTagsCommaSeparated = input(
                    message: 'Enter test tags to run in comma-separated format', 
                    parameters: [string(name: 'TEST_TAGS', trim: true)]
                  )

                  try {
                    runRobotTests(testTagsCommaSeparated)
                  } catch (Exception e) { 
                    echo "Failed to run robot tests: ${e.message}"
                  }
                }

                echo 'Specific tests done.'
              }
            }


            stage('Run Robot All Tests') {
              when {
                expression { env.CHANGE_TARGET == 'master' }
              }
              steps {
                echo 'All tests pending...'

                script {
                  try {
                    runRobotTests('all')
                  } catch (Exception e) {
                    echo "Failed to run robot tests: ${e.message}"
                  }
                }

                echo 'All tests done.'
              }
            }

            stage('Publish Robot Test Reports') {
              steps {
                script {
                  sh "docker network rm ${DOCKER_NETWORK_NAME}"
                }

                robot(
                  outputPath: "./results",
                  passThreshold: 90.0,
                  unstableThreshold: 80.0,
                  disableArchiveOutput: true,
                  outputFileName: "output.xml",
                  logFileName: 'log.html',
                  reportFileName: 'report.html',
                  countSkippedTests: true,
                )
              }
            }
          }
        }

        stage('Quality and Security Analysis') {
          stages {
            stage ('Run SonarQube Analysis') {
              environment {
                SONAR_SCANNER = tool name: 'SonarQubeScanner-7.0.2'
                SONAR_PROJECT_KEY = "recipe-suggester-ai-agent-api-tests"
              }

              steps {
                withSonarQubeEnv('SonarQube') {
                  sh "${SONAR_SCANNER}/bin/sonar-scanner -Dsonar.projectKey=${env.SONAR_PROJECT_KEY}"
                }
              }
            }

            stage('Quality Gate') {
              steps {
                script {
                  timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                  }
                }
              }
            }
          }
        }
      }
    }
  }


  post {
    always {
      echo "Job name: ${env.JOB_NAME}"
      echo "Build url: ${env.BUILD_URL}"
      echo "Build id: ${env.BUILD_ID}"
      echo "Build display name: ${env.BUILD_DISPLAY_NAME}"
      echo "Build number: ${env.BUILD_NUMBER}"
      echo "Build tag: ${env.BUILD_TAG}"
      echo "Branch name: ${env.BRANCH_NAME}"

      script {
        if (env.CHANGE_TARGET) {
          echo "Pull request from `${env.CHANGE_BRANCH}` to `${env.CHANGE_TARGET}`"
        }
      }

      script {
        def causes = currentBuild.getBuildCauses()
        causes.each { cause ->
          echo "Build cause: ${cause.shortDescription}"
        }

        cleanDanglingImages()

        // Prune images every 5 builds based on BUILD_ID
        if (env.BUILD_ID.toInteger() % 5 == 0) {
          echo "Pruning old Docker images..."
          sh 'yes | docker image prune -a'
        }
      }
    }
  }
}


void cleanDanglingImages() {
  sh '''
    danglingImages=$(docker images -f "dangling=true" -q)
    if [ -n "$danglingImages" ]; then
      docker image rmi $danglingImages
    else
      echo "No dangling images to remove."
    fi
  '''
}

void runRobotTests(String testTagsCommaSeparated) {
  docker.image(env.DOCKER_IMAGE_NAME_API_ROBOT_TEST).inside("--network=${env.DOCKER_NETWORK_NAME}") {
    echo 'Running health check...'
    sh "curl ${env.API_STAGING_BASE_URL}/api/operations/health"

    if (testTagsCommaSeparated == 'all') {
      echo "Running all tests..."
      sh "uv run pabot --outputdir ./results --testlevelsplit ./tests/suites"
      echo "Ran all tests."
    } else {
      testTagsCommaSeparated = testTagsCommaSeparated.replaceAll(/\s+/, '')

      String[] tagsArray = testTagsCommaSeparated.split(',')
      String tagFlags = tagsArray.collect {
        "--include $it"
      }.join(" ")

      echo "Running tests with flags: ${tagFlags}..."
      sh "uv run pabot ${tagFlags} --outputdir ./results --testlevelsplit ./tests/suites"
      echo "Ran tests with flags: ${tagFlags}."
    }
  }
}

void writeEnvFile(String directory, List<String> variables) {
  dir(directory) {
    echo "Writing .env file at ${directory}..."
    writeFile file: '.env', text: variables.join('\n')
    echo "Environment file created successfully at ${directory}."
  }
}

void buildDockerImage(String directory, String imageName) {
  dir(directory) {
    echo "Building ${imageName} image..."
    sh "docker build -t ${imageName} ."
    echo "${imageName} image built."
  }
}