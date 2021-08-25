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
            }
        }
        configure {
            def traitBlock = it / 'sources' / 'data' / 'jenkins.branch.BranchSource' / 'source' / 'traits'
            traitBlock << 'jenkins.plugins.git.traits.CloneOptionTrait' {
                extension(class: 'hudson.plugins.git.extensions.impl.CloneOption') {
                    shallow(true)
                    depth(1)
                    reference()
                    honorRefspec(true)
                }
            }
            traitBlock << 'jenkins.plugins.git.traits.BranchDiscoveryTrait' {}
            traitBlock << 'jenkins.scm.impl.trait.WildcardSCMHeadFilterTrait' {
                includes('*')
                excludes('solution*')
            }
        }
        orphanedItemStrategy {
            discardOldItems {
                numToKeep(20)
            }
        }
    }"},%{ endfor ~}]}
