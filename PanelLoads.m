classdef PanelLoads < handle
    properties
        uiPanel
        uiGrid
        uilabeledit_UniformLoad
        uilabeledit_PointLoad
        uilabeledit_PointLocation
        
        AppParent
    end

    properties (Constant)
        DefaultLoads = struct('Uniform',struct('W',0,'a',0,'b',[]), ...
            'Point',struct('F',0,'a',0));
        DefaultUniformLoad = 0;
        DefaultPointLoad = 0;
        DefaultUniformLocationA = 0;
        DefaultUniformLocationB = 0;
        DefaultPointLoadLocation = 0.1;
    end

    methods
        function obj = PanelLoads(appParent)
            obj.AppParent = appParent;
            uiParent = appParent.uiGrid;

            obj.uiPanel = uipanel('Parent',uiParent, ...
                'Units','pixels', ...  % 'Position',[40 580 425 320],
                'Tag','panelBeamLoads', ...
                'Title','Beam Loads', ...
                'FontSize',12, 'FontWeight','bold');
            obj.uiPanel.Layout.Row = 2;
            obj.uiPanel.Layout.Column = 2;

            % Grid Layout
            obj.uiGrid = uigridlayout(obj.uiPanel,[3 2]);  % appParent.hPanelTubeProperties
            obj.uiGrid.Padding = [10 8 10 8];
            obj.uiGrid.RowHeight = [22 22 22];

            obj.createFields;
        end

        function obj = createFields(obj)
            %% Edit Field Uniform Load
            r = 1; c = 1;
            uiLabelEditUniformLoad = uilabeledit(obj.uiGrid,r,c);  %#ok<*PROP>
            
            % uieditfield('numeric','Parent',obj.uiGrid, ...
            %    'Tag','editUniformLoad'); 
            obj.uilabeledit_UniformLoad = uiLabelEditUniformLoad;
            % uiLabelEditUniformLoad.Layout.Row = r;
            % uiLabelEditUniformLoad.Layout.Column = 2;
            
            uiLabelEditUniformLoad.uiEdit.Tag = "editUniformLoad";
            uiLabelEditUniformLoad.uiLabel.Text = "Uniform Load";

            uiLabelEditUniformLoad.uiEdit.Limits = [-Inf Inf]';
            uiLabelEditUniformLoad.uiEdit.LowerLimitInclusive = 'off';
            uiLabelEditUniformLoad.uiEdit.ValueDisplayFormat = '%.3f lbf/in';
            
            uiLabelEditUniformLoad.uiEdit.Value = obj.DefaultUniformLoad;
            uiLabelEditUniformLoad.uiEdit.ValueChangedFcn = @obj.handleEvents;

            %% Edit Field Point Load
            r = 2; c = 1;
            uiLabelEditPointLoad = uilabeledit(obj.uiGrid,r,c);
            
            % uieditfield('numeric','Parent',obj.uiGrid, ...
            %    'Tag','editUniformLoad'); 
            obj.uilabeledit_UniformLoad = uiLabelEditPointLoad;
            % uiLabelEditUniformLoad.Layout.Row = r;
            % uiLabelEditUniformLoad.Layout.Column = 2;
            
            uiLabelEditPointLoad.uiEdit.Tag = "editPointLoad";
            uiLabelEditPointLoad.uiLabel.Text = "Point Load";

            uiLabelEditPointLoad.uiEdit.Limits = [-Inf Inf]';
            uiLabelEditPointLoad.uiEdit.LowerLimitInclusive = 'off';
            uiLabelEditPointLoad.uiEdit.ValueDisplayFormat = '%.3f lbf';
            
            uiLabelEditPointLoad.uiEdit.Value = obj.DefaultUniformLoad;
            uiLabelEditPointLoad.uiEdit.ValueChangedFcn = @obj.handleEvents;
            
            %% Edit Field Point Load
            r = 3; c = 1;
            uiLabelEditPointLoadLocation = uilabeledit(obj.uiGrid,r,c);  %#ok<*PROP>
            
            % uieditfield('numeric','Parent',obj.uiGrid, ...
            %    'Tag','editUniformLoad'); 
            obj.uilabeledit_UniformLoad = uiLabelEditPointLoadLocation;
            % uiLabelEditUniformLoad.Layout.Row = r;
            % uiLabelEditUniformLoad.Layout.Column = 2;
            
            uiLabelEditPointLoadLocation.uiEdit.Tag = "editPointLoadLocation";
            uiLabelEditPointLoadLocation.uiLabel.Text = "Point Load Location";

            uiLabelEditPointLoadLocation.uiEdit.Limits = [0 Inf]';
            uiLabelEditPointLoadLocation.uiEdit.LowerLimitInclusive = 'on';
            uiLabelEditPointLoadLocation.uiEdit.ValueDisplayFormat = '%.3f in';
            
            uiLabelEditPointLoadLocation.uiEdit.Value = obj.DefaultPointLoadLocation;
            uiLabelEditPointLoadLocation.uiEdit.ValueChangedFcn = @obj.handleEvents;
        end

        function obj = r(obj)
        end

        function obj = handleEvents(obj,src,evt)
            value = src.Value;
            switch src.Tag
                case 'editUniformLoad'
                    obj.AppParent.Beam.LoadUniform.W = value;
                case 'editPointLoad'
                    obj.AppParent.Beam.LoadPoint.F = value;
                case 'editPointLoadLocation'
                    obj.AppParent.Beam.LoadPoint.a = value;
            end
        end
    end
end