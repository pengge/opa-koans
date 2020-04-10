package example

discovery = {
	"bundles": {"authz": {
		"service": "example_discovery",
		"resource": bundle_name,
		# do not polling bundle too frequently
		"polling": {
			"min_delay_seconds": 300,
			"max_delay_seconds": 600,
		},
	}},
	"default_decision": "rbac/allow",
	"decision_logs": {
		"service": "example_discovery",
		"partition_name": "discovery",
		# upload log gzip more frequently
		"reporting": {
			"min_delay_seconds": 30,
			"max_delay_seconds": 60,
		},
	},
	"status": {
		"service": "example_discovery",
		"partition_name": "discovery",
	},
}

rt = opa.runtime()

region = rt.config.labels.region

bundle_name = region_bundle[region]

# region-bundle information
region_bundle = {
	"US": "bundle/rbac.tar.gz",
	"UK": "bundle/rbac.tar.gz",
}
