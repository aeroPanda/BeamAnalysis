classdef PanelMaterial < handle
    properties
        uiPanel
        uiGrid
        AppParent

        MaterialName
        uiLabelEdit_Name
        uiLabelEdit_E
        uiLabelEdit_nu
    end

    methods
        function obj = PanelMaterial(appParent)
            obj.AppParent = appParent;
            uiParent = appParent.uiGrid;

            obj.uiPanel = uipanel('Parent',uiParent, ...
                'Units','pixels', ...  % 'Position',[40 580 425 320],
                'Tag','panelBeamMaterial', ...
                'Title','Beam Material', ...
                'FontSize',12, 'FontWeight','bold');
            obj.uiPanel.Layout.Row = 1;
            obj.uiPanel.Layout.Column = 2;

            % Grid Layout
            obj.uiGrid = uigridlayout(obj.uiPanel,[3 2]);  % appParent.hPanelTubeProperties
            obj.uiGrid.Padding = [10 8 10 8];
            obj.uiGrid.RowHeight = [22 22 22];

            obj.createFields
        end

        function obj = createFields(obj)
            r = 1; c = 1;
            uiLabelEdit_E = uilabeledit(obj.uiGrid,r,c);
            obj.uiLabelEdit_E = uiLabelEdit_E; %#ok<*PROP>
            uiLabelEdit_E.uiLabel.Text = "Modulus";
            uiLabelEdit_E.uiEdit.Tag = "editModulus";
            uiLabelEdit_E.uiEdit.Limits = [0 Inf]';
            uiLabelEdit_E.uiEdit.LowerLimitInclusive = 'off';
            uiLabelEdit_E.uiEdit.ValueDisplayFormat = '%.2f msi';
            
            uiLabelEdit_E.uiEdit.Value = 10.3;
            uiLabelEdit_E.uiEdit.ValueChangedFcn = @obj.handleEvents;
            evtInitialize.Origin = 'Value set on initialization';
            uiLabelEdit_E.uiEdit.ValueChangedFcn(uiLabelEdit_E.uiEdit,evtInitialize)  % Triggers event to set value immediately

            r = 2; c= 1;
            uiLabelEdit_nu = uilabeledit(obj.uiGrid,r,c);
            obj.uiLabelEdit_nu = uiLabelEdit_nu; %#ok<*PROP>
            uiLabelEdit_nu.uiLabel.Text = "Poisson Ratio";
            uiLabelEdit_nu.uiEdit.Tag = "editPoissonRatio";
            uiLabelEdit_nu.uiEdit.Limits = [0 Inf]';
            uiLabelEdit_nu.uiEdit.LowerLimitInclusive = 'off';
            uiLabelEdit_nu.uiEdit.ValueDisplayFormat = '%.2f';
            
            uiLabelEdit_nu.uiEdit.Value = 0.3;
            uiLabelEdit_nu.uiEdit.ValueChangedFcn = @obj.handleEvents;
            evtInitialize.Origin = 'Value set on initialization';
            uiLabelEdit_nu.uiEdit.ValueChangedFcn(uiLabelEdit_nu.uiEdit,evtInitialize)  % Triggers event to set value immediately
        end
        
        function handleEvents(obj,src,evt)
            value = src.Value;
            appParent = obj.AppParent;
            switch src.Tag
                case 'editModulus'
                    appParent.Beam.E = value * 1e6;
                case 'editPoissonRatio'
                    % appParent.Beam.E = value;
            end
        end

    end
end
