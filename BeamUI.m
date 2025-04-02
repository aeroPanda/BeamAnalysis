classdef BeamUI < matlab.apps.AppBase % handle
    properties
        uiGrid
        PanelMaterial
        PanelGeometry
        PanelLoads
        PanelBoundaryConditions
        uiButtonCalculate
        uiMainFigure
        
        BeamProperties PropertiesBeamI
        Beam BeamSingleSpan
    end

    methods
        function app = BeamUI()
            w = 1042;  h = 690;  positionXY = app.setScreenPosition(w, h);
            app.uiMainFigure = uifigure("Position",[positionXY w h]);
            app.uiGrid = uigridlayout("Parent",app.uiMainFigure);
            app.uiGrid.RowHeight = {240,360,'1x'};
            app.uiGrid.ColumnWidth = {420,420,'1x'};
            
            app.BeamProperties = PropertiesBeamI(0,0);  % tweb,hweb
            LBC = 'Simple';  RBC = 'Simple';
            Loads.Uniform.W = 0; Loads.Uniform.a = 0; Loads.Uniform.b = [];
            Loads.Point.F = 0; Loads.Point.a = 0;
            app.Beam = BeamSingleSpan(11,LBC,RBC,Loads);  % app.PanelGeometry.DefaultLengthBeam,LBC,RBC,Loads
            
            app.createPanel();
            
            %{
            tweb = app.PanelGeometry.DefaultThicknessWeb;
            hweb = app.PanelGeometry.DefaultHeightWeb;
            LBC = app.PanelBoundaryConditions.DefaultBC;
            RBC = app.PanelBoundaryConditions.DefaultBC;
            Loads = app.PanelLoads.DefaultLoads;
            %}
        end

        function app = createPanel(app)
            app.PanelGeometry = PanelGeometry(app); %#ok<*ADPROP>
            app.PanelBoundaryConditions = PanelBoundaryConditions(app);
            app.PanelMaterial = PanelMaterial(app);
            app.PanelLoads = PanelLoads(app);
            uiButtonCalculate = uibutton("Parent",app.uiGrid);
            app.uiButtonCalculate = uiButtonCalculate;
            uiButtonCalculate.Layout.Row = 3;
            uiButtonCalculate.Layout.Column = 1;
            uiButtonCalculate.Text = "Calculate";
            uiButtonCalculate.ButtonPushedFcn = @(src,evt)app.calculate;
        end

        function app = calculate(app)
            app.BeamProperties.calcProperties();
            app.Beam.I = app.BeamProperties.yyMomentOfArea2;
            app.Beam.calcShearMomentDeflection;
            app.Beam.plotShearMomentDeflection;
        end
    end

    methods (Static)
        function positionXY = setScreenPosition(w, h)
            positionXY = get(0,'PointerLocation');
            graphicsRoot = groot;
            monitorPositions = graphicsRoot.MonitorPositions;
            edgePosition = min([monitorPositions(:,3) - w, monitorPositions(:,4) - h], [], 1);
            positionXY(1) = min([edgePosition(1); positionXY(1)], [], 1);
            positionXY(2) = max([edgePosition(2); positionXY(2)], [], 1);
            positionXY(2) = positionXY(2) - h;
        end
    end

end





