### General
```
cwltool --no-container <workflow>.cwl clado-job.yml
```
---

### Extract coverage vector
```
cwltool --no-container coverage.cwl clado-job.yml
```

### Fetch metadata
```
cwltool --preserve-entire-environment --no-container metadata.cwl clado-job.yml
```

### Generate cladogram
```
R_PACKAGES="${HOME}/RLibraries" \
cwltool --preserve-entire-environment --no-container \
cladogram.cwl clado-job.yml
```

### Generate newick tree for auspice (nextstrain)
```
R_PACKAGES=${HOME}/RLibraries \
TAXOPHAGES_ENV=server \
cwltool --preserve-entire-environment --no-container \
newick.cwl clado-job.yml
```

### 
```
AUGUR_RECURSION_LIMIT=30000 \
cwltool --preserve-entire-environment --no-container \
augur.cwl clado-job.yml
```

### Run the entire phylogeny workflow to get a tree that can be ran by auspice
```
R_PACKAGES="${HOME}/RLibraries" \
TAXOPHAGES_ENV=server \
AUGUR_RECURSION_LIMIT=30000 \
cwltool --preserve-entire-environment --no-container phylogeny.cwl clado-job.yml
```
