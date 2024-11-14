---
layout: default
title: Runbook Updates
type: Informational
parent: Documentation Contribution
---

Informational
{: .label }

## Follow the runbook guideline
Please read and follow the [runbook guide](runbook_guideline.html) when adding your runbooks, otherwise your runbook may not pass the runbook build check and therefore will not be merged.  


## How to add a runbook to Armada Docs

1. Follow instructions for creating a pull request [here](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/CONTRIBUTING.md)
1. Create a markdown file (.md) for your runbook and place it in `documentation.pages/docs/runbooks`
    1. Make sure you add the metadata used to describe the runbook. This is used to populate lists of runbooks and to help searching for runbooks.
    1. The content can be specified using just markdown language. A basic markdown tutorial can be found [here](http://markdowntutorial.com/). If markdown extensions are used, please follow the [Kramdown extended syntax](http://kramdown.gettalong.org/syntax.html).
    1. If the runbook is already developed in html format, then the html can be imbedded directly into the markdown file. See the documentation.pages/docs/runbooks/restart_deploy_regsitry.md file as an example.
1. Instructions to view the rendered documentation locally before committing the changes can be found in [Running locally](/docs/README.html).
1. **`documentation-pages/assets/json/runbook-list.json` now is automatically generated via liquid template language, there is no need to run script/RunbookJsonGenerator.py  any longer.**  
1. **With this tool that generates the json, `documentation.pages/assets/json/runbook-list.json`; You still need to ensure the meta is correct at the top of your runbook!!**
