{ Altium PCB Ultra-Compact Layout Script v3 }
{ All components packed within ~80x50mm board area }
{ Origin = board bottom-left corner (0,0) }

procedure OptimizePCBLayout;
var
  Board    : IPCB_Board;
  Comp     : IPCB_Component;
  Iterator : IPCB_BoardIterator;
  Name     : String;
  idx, col, row : Integer;
begin
  Board := PCBServer.GetCurrentPCBBoard;
  if Board = nil then begin ShowMessage('No PCB open!'); Exit; end;

  PCBServer.PreProcess;

  Iterator := Board.BoardIterator_Create;
  Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
  Iterator.AddFilter_LayerSet(AllLayers);
  Iterator.AddFilter_Method(eProcessAll);

  Comp := Iterator.FirstPCBObject;
  while Comp <> nil do
  begin
    Name := Comp.Name.Text;

    { === BLOCK A: USB-C Input (far left, tightly stacked) === }
    if    (Name = 'J4')    then begin Comp.X := MMsToCoord(5);  Comp.Y := MMsToCoord(25); end
    else if (Name = 'U1')  then begin Comp.X := MMsToCoord(13); Comp.Y := MMsToCoord(25); end
    else if (Name = 'CC1') then begin Comp.X := MMsToCoord(13); Comp.Y := MMsToCoord(22); end
    else if (Name = 'CC2') then begin Comp.X := MMsToCoord(13); Comp.Y := MMsToCoord(28); end
    else if (Name = 'VBUS1') then begin Comp.X := MMsToCoord(18); Comp.Y := MMsToCoord(25); end

    { === BLOCK B: I2C / Signal Header (just right of USB block) === }
    else if (Name = 'SDA1') then begin Comp.X := MMsToCoord(22); Comp.Y := MMsToCoord(27); end
    else if (Name = 'SCL1') then begin Comp.X := MMsToCoord(22); Comp.Y := MMsToCoord(23); end

    { === BLOCK C: Main IC - CENTER of board === }
    else if (Name = 'IM1') then begin Comp.X := MMsToCoord(45); Comp.Y := MMsToCoord(25); end

    { === BLOCK D: Gate Driver / Sub-IC (just left of IM1) === }
    else if (Name = 'I1')  then begin Comp.X := MMsToCoord(37); Comp.Y := MMsToCoord(25); end
    else if (Name = 'I2')  then begin Comp.X := MMsToCoord(37); Comp.Y := MMsToCoord(20); end
    else if (Name = 'I3')  then begin Comp.X := MMsToCoord(37); Comp.Y := MMsToCoord(30); end
    else if (Name = 'I4')  then begin Comp.X := MMsToCoord(41); Comp.Y := MMsToCoord(20); end
    else if (Name = 'ILIM1') then begin Comp.X := MMsToCoord(55); Comp.Y := MMsToCoord(30); end

    { === BLOCK E: Switch + Passives (right of IM1, tight cluster) === }
    else if (Name = 'SW1') then begin Comp.X := MMsToCoord(57); Comp.Y := MMsToCoord(25); end
    else if (Name = 'R1')  then begin Comp.X := MMsToCoord(60); Comp.Y := MMsToCoord(22); end
    else if (Name = 'R2')  then begin Comp.X := MMsToCoord(60); Comp.Y := MMsToCoord(28); end
    else if (Name = 'RB5') then begin Comp.X := MMsToCoord(63); Comp.Y := MMsToCoord(25); end
    else if (Name = 'D1')  then begin Comp.X := MMsToCoord(65); Comp.Y := MMsToCoord(28); end
    else if (Name = 'D2')  then begin Comp.X := MMsToCoord(65); Comp.Y := MMsToCoord(22); end

    { === BLOCK F: J3 Connector (bottom-center, inside board) === }
    else if (Name = 'J3')  then begin Comp.X := MMsToCoord(40); Comp.Y := MMsToCoord(8);  end

    { === BLOCK G: Test Points - 2 tight rows at top === }
    { Row 1 (CP1-CP10): Y=44, Row 2 (CP11-CP19): Y=48 }
    else if Copy(Name, 1, 2) = 'CP' then
    begin
      idx := StrToIntDef(Copy(Name, 3, Length(Name)), 1);
      col := (idx - 1) mod 10;
      row := (idx - 1) div 10;
      Comp.X := MMsToCoord(10 + col * 6);
      Comp.Y := MMsToCoord(44 + row * 4);
    end;

    Comp.GraphicallyInvalidate;
    Comp := Iterator.NextPCBObject;
  end;

  Board.BoardIterator_Destroy(Iterator);
  PCBServer.PostProcess;
  Board.ViewManager_FullUpdate;
  ShowMessage('v3 Done! Check all components are inside board outline, then Auto Route.');
end;

procedure TFormOptimize.btnRunClick(Sender: TObject);
begin
  OptimizePCBLayout;
end;
