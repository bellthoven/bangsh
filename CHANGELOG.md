* Improve `bang new` adding the `tests/` directory
* Makes `tasks` the default way of building `bang.sh` scripts
* Fixes `opt` module when parsing more then 5 options #24 [bug]
* Fixes the `which -s` bug for not BSD versions of `which` #23 [bug]
* Add the `bang run` task. It must be used as entry point for bang apps
* Fix `b.opt.show_usage` that was not showing options due to problems on echoing options
* Add `b.depends_on` using the [@coderofsalvation Pull Request](https://github.com/bellthoven/bangsh/pull/10)
