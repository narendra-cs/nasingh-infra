variable "airflow_vars" {
    type    = map(map(string))
    default = {
        dev = {
            env = "dev",
            bid_pct = 80,
        },
        prod = {
            env = "prod",
            bid_pct = 80,
        },
        sandbox = {
            env = "dev",
            bid_pct = 80,
        },
        # Empty variables - assumed if no evironment-specific variables were defined
        empty = {
        }
    }
}