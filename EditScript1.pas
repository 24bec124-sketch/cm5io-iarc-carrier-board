{ CM5IO DRC Rules - LionCircuits Constraints
  Altium Designer DelphiScript (.pas)
  Run: Scripts > Run Script > RunAll }

procedure SetupDRCRules;
var
  Board   : IPCB_Board;
  RuleMan : IPCB_RulesManager;
  WRule   : IPCB_WidthConstraintRule;
  CRule   : IPCB_ClearanceConstraintRule;
  ERule   : IPCB_BoardEdgeClearanceRule;
  HRule   : IPCB_HoleSizeConstraintRule;
  SMRule  : IPCB_SolderMaskExpansionRule;
  DPRule  : IPCB_DiffPairsRoutingRule;
begin
  Board := PCBServer.GetCurrentPCBBoard;
  if Board = nil then
  begin
    ShowMessage('ERROR: Open a PCB document first.');
    Exit;
  end;

  PCBServer.PreProcess;
  RuleMan := Board.Rules;

  { --- 1. MIN TRACE WIDTH: 6mil --- }
  WRule := PCBServer.PCBRuleFactory(eWidthConstraint);
  WRule.Name       := 'MinTraceWidth_6mil';
  WRule.Comment    := 'LionCircuits 1oz: min 6mil trace width';
  WRule.MinWidth   := MilsToCoord(6);
  WRule.MaxWidth   := MilsToCoord(200);
  WRule.PrefWidth  := MilsToCoord(6);
  RuleMan.AddRule(WRule);

  { --- 2. MIN CLEARANCE trace-trace: 6mil --- }
  CRule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  CRule.Name         := 'MinClearance_6mil';
  CRule.Comment      := 'LionCircuits: trace-trace min 6mil';
  CRule.MinClearance := MilsToCoord(6);
  RuleMan.AddRule(CRule);

  { --- 3. TRACE TO COPPER POUR: 6mil --- }
  CRule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  CRule.Name         := 'TraceToPour_6mil';
  CRule.Comment      := 'LionCircuits: trace to copper pour 6mil';
  CRule.MinClearance := MilsToCoord(6);
  RuleMan.AddRule(CRule);

  { --- 4. BOARD EDGE CLEARANCE: 12mil (0.3mm) --- }
  ERule := PCBServer.PCBRuleFactory(eBoardEdgeClearanceConstraint);
  ERule.Name              := 'BoardEdge_12mil';
  ERule.Comment           := 'LionCircuits: circuit to edge 0.3mm/12mil';
  ERule.BoardEdgeClearance := MilsToCoord(12);
  RuleMan.AddRule(ERule);

  { --- 5. VIA TO VIA: 12mil --- }
  CRule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  CRule.Name         := 'ViaToVia_12mil';
  CRule.Comment      := 'LionCircuits: via to via min 12mil';
  CRule.MinClearance := MilsToCoord(12);
  RuleMan.AddRule(CRule);

  { --- 6. VIA TO TRACE: 12mil --- }
  CRule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  CRule.Name         := 'ViaToTrace_12mil';
  CRule.Comment      := 'LionCircuits: via to trace min 12mil';
  CRule.MinClearance := MilsToCoord(12);
  RuleMan.AddRule(CRule);

  { --- 7. SILK TO PAD: 6mil --- }
  CRule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  CRule.Name         := 'SilkToPad_6mil';
  CRule.Comment      := 'LionCircuits: silkscreen to pad 6mil';
  CRule.MinClearance := MilsToCoord(6);
  RuleMan.AddRule(CRule);

  { --- 8. SOLDER MASK EXPANSION: 3mil per side (6mil dam) --- }
  SMRule := PCBServer.PCBRuleFactory(eSolderMaskExpansion);
  SMRule.Name      := 'SolderMaskDam_6mil';
  SMRule.Comment   := 'LionCircuits: solder mask expansion 3mil/side';
  SMRule.Expansion := MilsToCoord(3);
  RuleMan.AddRule(SMRule);

  { --- 9. DRILL HOLE SIZE: 0.35mm min, 6.3mm max --- }
  HRule := PCBServer.PCBRuleFactory(eHoleSizeConstraint);
  HRule.Name            := 'DrillHole_0p35_6p3mm';
  HRule.Comment         := 'LionCircuits: drill 0.35-6.3mm';
  HRule.MinimumHoleSize := MMsToCoord(0.35);
  HRule.MaximumHoleSize := MMsToCoord(6.3);
  RuleMan.AddRule(HRule);

  { --- 10. DIFF PAIR 100 OHM (PCIe / HDMI / MIPI / USB3-SS)
       Calculated: W=0.18mm, S=0.20mm ? Zdiff=101.7O
       Stackup: H=0.12mm, Er=4.2, T=0.035mm --- }
  DPRule := PCBServer.PCBRuleFactory(eDiffPairsRoutingConstraint);
  DPRule.Name      := 'DiffPair_100R';
  DPRule.Comment   := '100R diff: PCIe/HDMI/MIPI/USB3SS | W=0.18mm G=0.20mm';
  DPRule.MinWidth  := MMsToCoord(0.16);
  DPRule.MaxWidth  := MMsToCoord(0.20);
  DPRule.PrefWidth := MMsToCoord(0.18);
  DPRule.MinGap    := MMsToCoord(0.18);
  DPRule.MaxGap    := MMsToCoord(0.22);
  DPRule.PrefGap   := MMsToCoord(0.20);
  RuleMan.AddRule(DPRule);

  { --- 11. DIFF PAIR 90 OHM (USB2.0 / USB OTG)
       Calculated: W=0.20mm, S=0.20mm ? Zdiff=95.5O (within ±10%)
       Stackup: H=0.12mm, Er=4.2, T=0.035mm --- }
  DPRule := PCBServer.PCBRuleFactory(eDiffPairsRoutingConstraint);
  DPRule.Name      := 'DiffPair_90R_USB';
  DPRule.Comment   := '90R diff: USB2.0/OTG | W=0.20mm G=0.20mm';
  DPRule.MinWidth  := MMsToCoord(0.18);
  DPRule.MaxWidth  := MMsToCoord(0.22);
  DPRule.PrefWidth := MMsToCoord(0.20);
  DPRule.MinGap    := MMsToCoord(0.18);
  DPRule.MaxGap    := MMsToCoord(0.22);
  DPRule.PrefGap   := MMsToCoord(0.20);
  RuleMan.AddRule(DPRule);

  PCBServer.PostProcess;
  Board.GraphicallyInvalidate;

  ShowMessage(
    'All Rules Applied OK!' + #13#10 +
    #13#10 +
    'Min Trace Width   : 6mil' + #13#10 +
    'Min Clearance     : 6mil' + #13#10 +
    'Board Edge        : 12mil' + #13#10 +
    'Via-Via/Trace     : 12mil' + #13#10 +
    'Solder Mask       : 3mil expansion' + #13#10 +
    'Drill             : 0.35-6.3mm' + #13#10 +
    '100R Diff (PCIe/HDMI/MIPI): W=0.18mm G=0.20mm' + #13#10 +
    '90R  Diff (USB2/OTG):       W=0.20mm G=0.20mm' + #13#10 +
    #13#10 +
    'Set net scopes manually:' + #13#10 +
    'Design > Rules > High Speed > Diff Pairs Routing'
  );
end;

procedure RunAll;
begin
  SetupDRCRules;
end;
