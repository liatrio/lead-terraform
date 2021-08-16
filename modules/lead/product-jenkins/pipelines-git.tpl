{"jobs":[%{ for name,pipeline in pipelines ~}{"script":"
    folder('${pipeline.org}') {
    }
    multibranchPipelineJob('${pipeline.org}/${pipeline.repo}') {
        triggers {
            periodic(1)
        }
        branchSources {
            git {
                id('https://www.github.com/${pipeline.org}/${pipeline.repo}.git')
                remote('https://www.github.com/${pipeline.org}/${pipeline.repo}.git')
                excludes('solution*')
                extensions {
                    cloneOptions {
                        shallow()
                    }
                }
            }
        }
        orphanedItemStrategy {
            discardOldItems {
                numToKeep(20)
            }
        }
    }"},%{ endfor ~}]}
