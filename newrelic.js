'use strict'

/**
 * New Relic agent configuration.
 *
 * See lib/config.defaults.js in the agent distribution for a more complete
 * description of configuration variables and their potential values.
 */
exports.config = {
  /**
   * Array of application names.
   */
  //app_name: ['iqdndbot'],
  // NEW_RELIC_APP_NAME environment var
  /**
   * Your New Relic license key.
   */
  //license_key: 'license key here',
  // NEWRELIC_LICENSE_KEY environment var
  logging: {
    /**
     * Level at which to log. 'trace' is most useful to New Relic when diagnosing
     * issues with the agent, 'info' and higher will impose the least overhead on
     * production applications.
     */
    level: 'info'
  }
}
