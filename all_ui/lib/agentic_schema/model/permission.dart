enum Permission {
  // Workflow permissions
  workflowView,
  workflowEdit,
  workflowDelete,
  workflowExecute,
  workflowPublish,

  // Node permissions
  nodeCreate,
  nodeEdit,
  nodeDelete,

  // Collaboration permissions
  inviteUsers,
  managePermissions,
  viewAuditLog,

  // Organization permissions
  manageOrganization,
  manageBilling,
  manageIntegrations,

  // Admin permissions
  systemAdmin,
}
