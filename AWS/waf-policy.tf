
resource "aws_wafv2_web_acl" "eps-aws-unmanaged" {
  name        = "eps-eim12345-aws-applicationname-unmanaged"
  scope       = "REGIONAL"
  description = "Full configuration WAF ACL"
  
  default_action {
    allow {}
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "acl-full"
    sampled_requests_enabled   = true
  }
  
   # Staging AWSManagedRulesCommonRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet-count"
    priority = 100
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
        version     = "Version_1.14"
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "NoUserAgent_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_QUERYSTRING"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_Cookie_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_BODY"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_URIPATH"
        }
  
  
  
      }
    }
  }
   
    # Production AWSManagedRulesCommonRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet-block"
    priority = 110
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet-block"
      sampled_requests_enabled   = true
  
    }
  
  
    statement {
  
      managed_rule_group_statement {
  
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
        version     = "Version_1.14"
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "NoUserAgent_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_QUERYSTRING"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_Cookie_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_BODY"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "SizeRestrictions_URIPATH"
        }
      }
    }
  }
  
  
    
  # Staging AWSManagedRulesSQLiRuleset
  
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet-count"
    priority = 120
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
        version     = "Version_1.2"
  
      }
    }
  }
  
 # Production AWSManagedRulesSQLiRuleset
  
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet-block"
    priority = 130
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
        version     = "Version_1.2"
  
      }
    }
  }
  
  
  
  
  # Staging AWSManagedRulesKnownBadInputsRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet-count"
    priority = 140
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        version     = "Version_1.22"
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_QUERYSTRING"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_BODY"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_URIPATH"
        }
  
      }
    }
  }
  
      # Production AWSManagedRulesKnownBadInputsRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet-block"
    priority = 150
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        version     = "Version_1.22"
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_HEADER"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_QUERYSTRING"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_BODY"
        }
  
        rule_action_override {
          action_to_use {
            count {}
  
          }
          name = "Log4JRCE_URIPATH"
        }
  
      }
    }
  }   
  
  
  # Staging AWSManagedRulesLinuxRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet-count"
    priority = 160
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesLinuxRuleSet"
        version     = "Version_2.4"
  
      }
    }
  }
  
# Production AWSManagedRulesLinuxRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet-block"
    priority = 170
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesLinuxRuleSet"
        version     = "Version_2.4"
  
      }
    }
  }
  
  
  
  
  # Staging AWSManagedRulesWindowsRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesWindowsRuleSet-count"
    priority = 180
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWindowsRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesWindowsRuleSet"
        version     = "Version_2.2"
  
      }
    }
  }
  
  
   # Production AWSManagedRulesWindowsRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesWindowsRuleSet-block"
    priority = 190
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWindowsRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesWindowsRuleSet"
        version     = "Version_2.2"
  
      }
    }
  }
  
  
  # Staging AWSManagedRulesPHPRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet-count"
    priority = 200
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesPHPRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesPHPRuleSet"
        version     = "Version_2.1"
  
      }
    }
  }
  
   # Production AWSManagedRulesPHPRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet-block"
    priority = 210
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesPHPRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesPHPRuleSet"
        version     = "Version_2.1"
  
      }
    }
  }
  
  
  # Staging AWSManagedRulesAdminProtectionRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesAdminProtectionRuleSet-count"
    priority = 220
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAdminProtectionRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        version     = "Version_1.1"
  
      }
    }
  }
  
      # Production AWSManagedRulesAdminProtectionRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesAdminProtectionRuleSet-block"
    priority = 230
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAdminProtectionRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        version     = "Version_1.1"
  
      }
    }
  }    
  
  
  # Staging AWSManagedRulesWordPressRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesWordPressRuleSet-count"
    priority = 240
  
    override_action {
      count {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWordPressRuleSet-count"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesWordPressRuleSet"
        version     = "Version_1.3"
  
      }
    }
  }
  
# Production AWSManagedRulesWordPressRuleSet
  
  rule {
    name     = "AWS-AWSManagedRulesWordPressRuleSet-block"
    priority = 250
  
    override_action {
      none {}
    }
  
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWordPressRuleSet-block"
      sampled_requests_enabled   = true
    }
  
    statement {
  
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesWordPressRuleSet"
        version     = "Version_1.3"
  
      }
    }
  } 
}