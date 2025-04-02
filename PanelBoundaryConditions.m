classdef PanelBoundaryConditions < handle
    properties (Access = public)
        uiPanel
        uiGrid
        AppParent
        uiTable_BC

        numSupports
        
    end

    properties (Constant)
        DefaultNumBC = 2
        DefaultBC = "Simple"
    end
    
    methods (Access = public)
        function obj = PanelBoundaryConditions(appParent)
            obj.AppParent = appParent;
            uiParent = appParent.uiGrid;

            obj.uiPanel = uipanel('Parent',uiParent, ...
                'Units','pixels', ...  % 'Position',[40 580 425 320],
                'Tag','panelBeamGeometry', ...
                'Title','Beam Supports', ...
                'FontSize',12, 'FontWeight','bold');
            obj.uiPanel.Layout.Row = 2;
            obj.uiPanel.Layout.Column = 1;

            % Grid Layout
            obj.uiGrid = uigridlayout(obj.uiPanel,[3 2]);  % appParent.hPanelTubeProperties
            obj.uiGrid.Padding = [10 8 10 8];
            obj.uiGrid.RowHeight = [22 200];

            % Create Fields
            obj.createFields();

        end
        
        function obj = createFields(obj)
            %% Number of Boundary Conditions
            r = 1;  c = 1;
            uiLabelEdit_BC = uilabeledit(obj.uiGrid,r,c);
            uiLabelEdit_BC.uiLabel.Text = "Number of Supports";
            uiLabelEdit_BC.uiEdit.Value = obj.DefaultNumBC;
            uiLabelEdit_BC.uiEdit.Limits = [0 10]';
            uiLabelEdit_BC.uiEdit.Tag = "editNumSupports";
            uiLabelEdit_BC.uiEdit.ValueChangedFcn = @obj.handleEvents;
            numBC = obj.DefaultNumBC;

            r = 2; c = [1 2];
            uiTable_BC = uitable("Parent",obj.uiGrid); %#ok<*PROP>
            obj.uiTable_BC = uiTable_BC;
            uiTable_BC.Layout.Row = r;
            uiTable_BC.Layout.Column = c;
            
            t = table( [num2cell((1:numBC)') repmat({obj.DefaultBC},numBC,1)] );
            uiTable_BC.ColumnFormat = {[] {'Fixed','Simple','Free'}};  % {"Fixed","Simple","Free"}
            uiTable_BC.ColumnEditable = [false true];
            uiTable_BC.Data = t;
            uiTable_BC.ColumnName = ["BC", "BC Type"];
            
            uiTable_BC.Tag = "tableSupportBC";
        end

        function handleEvents(obj,src,evt)
            switch src.Tag
                case 'editNumSupports'
                    numSupports = src.Value;  obj.numSupports = numSupports;
                    t = obj.uiTable_BC.Data;
                    s_t = size(t);
                    if s_t(1) < numSupports
                        numNewSupports = numSupports-s_t(1);
                        t = [t; [num2cell((1:numNewSupports)') repmat(obj.DefaultBC,numNewSupports,1)]];
                    else
                        t = t(1:numSupports,:);
                    end
                    obj.uiTable_BC.Data = t;
                case 'tableSupportBC'
            end
        end
    end
end