classdef PanelGeometry < handle %matlab.apps.AppBase %
    properties (Access = public)        
        uiPanel
        uiGrid
        
        uiLabelBeamMaterial
        uiDropdownBeamMaterial

        uiLabelLengthBeam
        uiEditLengthBeam
        
        uiLabelHeightWeb
        uiEditHeightWeb

        uiLabelThicknessWeb
        uiEditThicknessWeb
        
        % uiLabelTubeOuterDiameter
        % uiEditTubeOuterDiameter
        
        % uiLabelTubeWallThickness
        % uiEditTubeWallThickness
        
        % uiLabelUnsupportedLength
        % uiEditUnsupportedLength
        
        bgSupportConditions
        uiTextNaturalFrequencies
        
        % uiLabelTubeJoint
        % uiDropdownTubeJoint
        
        % uiLabelSafetyFactors
        % uiDropdownSafetyFactors
        
        AppParent
        MaterialNames
    end
    
    properties (Constant)
        DefaultLengthBeam = 11.0;
        DefaultWidthUpperCap = 1.0
        DefaultWidthLowerCap = 1.0
        DefaultThicknessUpperCap = 0.1
        DefaultThicknessLowerCap = 0.1
        DefaultThicknessWeb = 0.1
        DefaultHeightWeb = 1.0
    end

    methods (Access = public)
        function obj = PanelGeometry(appParent)
            obj.AppParent = appParent;
            uiParent = appParent.uiGrid;

            obj.uiPanel = uipanel('Parent',uiParent, ...
                'Units','pixels', ...  % 'Position',[40 580 425 320],
                'Tag','panelBeamGeometry', ...
                'Title','Beam Geometry', ...
                'FontSize',12, 'FontWeight','bold');
            obj.uiPanel.Layout.Row = 1;
            obj.uiPanel.Layout.Column = 1;
            
            % Grid Layout
            obj.uiGrid = uigridlayout(obj.uiPanel,[9 2]);  % appParent.hPanelTubeProperties
            obj.uiGrid.Padding = [10 8 10 8];
            obj.uiGrid.RowHeight = [22 24 24 24 22 22 22 22 22];
            
            %% Create Fields
            obj.createFields            
        end
        
        function obj = createFields(obj)
            %% Edit Field Beam Length
            r = 1;
            uiEditLengthBeam = uieditfield('numeric','Parent',obj.uiGrid, ...
                'Tag','editLengthBeam'); %#ok<*PROP>
            obj.uiEditLengthBeam = uiEditLengthBeam;
            uiEditLengthBeam.Layout.Row = r;
            uiEditLengthBeam.Layout.Column = 2;

            uiEditLengthBeam.Limits = [0 Inf]';
            uiEditLengthBeam.LowerLimitInclusive = 'off';
            uiEditLengthBeam.ValueDisplayFormat = '%.3f in';
            
            uiEditLengthBeam.Value = obj.DefaultLengthBeam;
            uiEditLengthBeam.ValueChangedFcn = @obj.handleEvents;
            evtInitialize.Origin = 'Value set on initialization';
            uiEditLengthBeam.ValueChangedFcn(uiEditLengthBeam,evtInitialize)  % Triggers event to set value immediately

            % Label Beam Length
            uiLabelLengthBeam = uilabel('Parent',obj.uiGrid, ...
                'Tag','labelTubeOuterDiameter', 'HorizontalAlignment','left');
            obj.uiLabelLengthBeam = uiLabelLengthBeam;
            uiLabelLengthBeam.Layout.Row = r;
            uiLabelLengthBeam.Layout.Column = 1;
            uiLabelLengthBeam.Text = 'Beam Length [in] =';  % label text

            %% Edit Field Web Height
            r = r + 1;
            uiEditThicknessWeb = uieditfield('numeric','Parent',obj.uiGrid, ...
                'Tag','editHeightWeb');
            obj.uiEditHeightWeb = uiEditThicknessWeb;
            uiEditThicknessWeb.Layout.Row = r;
            uiEditThicknessWeb.Layout.Column = 2;

            uiEditThicknessWeb.Limits = [0 Inf]';
            uiEditThicknessWeb.LowerLimitInclusive = 'off';
            uiEditThicknessWeb.ValueDisplayFormat = '%.3f in';
            
            uiEditThicknessWeb.Value = obj.DefaultHeightWeb;
            uiEditThicknessWeb.ValueChangedFcn = @obj.handleEvents;
            evtInitialize.Origin = 'Value set on initialization';
            uiEditThicknessWeb.ValueChangedFcn(uiEditThicknessWeb,evtInitialize)  % Triggers event to set value immediately

            % Label Web Height
            uiLabelThicknessWeb = uilabel('Parent',obj.uiGrid, ...
                'Tag','labelTubeOuterDiameter', 'HorizontalAlignment','left');
            obj.uiLabelHeightWeb = uiLabelThicknessWeb;
            uiLabelThicknessWeb.Layout.Row = r;
            uiLabelThicknessWeb.Layout.Column = 1;
            uiLabelThicknessWeb.Text = 'Web Height [in] =';  % label text

            %% Edit Field Web Thickness
            r = r + 1;
            uiEditThicknessWeb = uieditfield('numeric','Parent',obj.uiGrid, ...
                'Tag','editThicknessWeb');
            obj.uiEditThicknessWeb = uiEditThicknessWeb;
            uiEditThicknessWeb.Layout.Row = r;
            uiEditThicknessWeb.Layout.Column = 2;

            uiEditThicknessWeb.Limits = [0 Inf]';
            uiEditThicknessWeb.LowerLimitInclusive = 'off';
            uiEditThicknessWeb.ValueDisplayFormat = '%.3f in';
            
            uiEditThicknessWeb.Value = obj.DefaultThicknessWeb;
            uiEditThicknessWeb.ValueChangedFcn = @obj.handleEvents;
            evtInitialize.Origin = 'Value set on initialization';
            uiEditThicknessWeb.ValueChangedFcn(uiEditThicknessWeb,evtInitialize)  % Triggers event to set value immediately

            % Label Web Thickness
            uiLabelThicknessWeb = uilabel('Parent',obj.uiGrid, ...
                'Tag','labelTubeOuterDiameter', 'HorizontalAlignment','left');
            obj.uiLabelThicknessWeb = uiLabelThicknessWeb;
            uiLabelThicknessWeb.Layout.Row = r;
            uiLabelThicknessWeb.Layout.Column = 1;
            uiLabelThicknessWeb.Text = 'Web Thickness [in] =';  % label text
        end

        function handleEvents(obj,src,evt)
            value = src.Value;
            appParent = obj.AppParent;
            switch src.Tag
                case 'editLengthBeam'
                    appParent.Beam.L = value;
                case 'editHeightWeb'
                    appParent.BeamProperties.hweb = value;
                    appParent.BeamProperties.calcProperties();
                    appParent.Beam.I = appParent.BeamProperties.yyMomentOfArea2;
                case 'editThicknessWeb'
                    appParent.BeamProperties.tweb = value;
                    appParent.BeamProperties.calcProperties();
                    appParent.Beam.I = appParent.BeamProperties.yyMomentOfArea2;
            end
        end
        
    end

end