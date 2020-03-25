{
%{ for name,pipeline in pipelines ~}
  ${name}: {
    type: ${pipeline.type},
    repo: ${pipeline.repo},
    org: ${pipeline.org}
  },
%{ endfor ~}}
