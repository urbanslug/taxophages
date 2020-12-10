General
```
cwltool --no-container <workflow>.cwl clado-job.yml
```

Extract coverage vector
```
cwltool --no-container coverage.cwl clado-job.yml
```

Fetch metadata
```
cwltool --preserve-entire-environment --no-container metadata.cwl clado-job.yml
```
