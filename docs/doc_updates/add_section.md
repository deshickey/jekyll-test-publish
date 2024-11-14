---
layout: default
title: Adding a documentation
type: Informational
parent: Documentation Contribution
---

Informational
{: .label }

## Steps to follow to add a new section to Armada Docs:

* Follow instructions for creating a pull request [here](https://github.ibm.com/alchemy-conductors/documentation-pages/blob/master/CONTRIBUTING.md)
* Create a new folder in the documentation.pages/docs directory for the new documentation section.
* Add a link for the new section in the documentation.pages/_includes/docs-toc.html file.
* Create a markdown file(s) (.md) for the new section and place it in the new folder created above. The content of the markdown file can be in the following formats:
  * The content can be specified using just markdown language. A basic markdown tutorial can be found [here](http://markdowntutorial.com/). If markdown extensions are used, please follow the [Kramdown extended syntax](http://kramdown.gettalong.org/syntax.html).
  * If the content is already in html format, then the html can be imbedded directly into the markdown file. See the documentation.pages/docs/runbooks/restart_deploy_regsitry.md file as an example.
* Add a link for the new content in the new section of the documentation.pages/_includes/docs-toc.html file.
* Instructions to view the rendered documentation locally before committing the changes can be found in [Running locally](/docs/README.html).

