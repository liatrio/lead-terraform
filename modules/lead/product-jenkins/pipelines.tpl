{"jobs":[%{ for name,pipeline in pipelines ~}{"script":"
    folder('${pipeline.org}') {
    }
    multibranchPipelineJob('${pipeline.org}/${pipeline.repo}') {
        triggers {
            periodic(1)
        }
        branchSources {
            github {
                id('https://www.github.com/${pipeline.org}/${pipeline.repo}.git')
                repoOwner('${pipeline.org}')
                repository('${pipeline.repo}')
                excludes('solution*')
            }
        }
        orphanedItemStrategy {
            discardOldItems {
                numToKeep(20)
            }
        }
    }"},%{ endfor ~}]}
