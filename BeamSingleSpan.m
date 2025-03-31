classdef BeamSingleSpan < matlab.mixin.Copyable
% Original Author:  Alek Xu
% Original Date:    2025/03/29
% Last Modified On: 2025/03/31
    properties (SetObservable, Access = public)
        Increment = 0.01
        x double
        L  % Beam Length
        LeftBoundaryCondition string  % 1
        RightBoundaryCondition string  % 2
        BoundaryConditions

        E  % Modulus % MaterialProperties = struct('E',[])
        I  % Second Moment of Area % SectionProperties = struct('I',[])

        LoadUniform = struct('W',0,'a',[],'b',[])
        LoadPoint = struct('F',0,'a',[])
        
        %% Outputs
        M
        V  % dM_dx
        MUniform
        MPoint
        
        Y
        dY_dx
        YUniform
        YPoint
        
        R1
        R2
        M1
        M2
    end

    methods
        function obj = BeamSingleSpan(L,LBC,RBC,Loads)
            switch nargin
                case 4
                    obj.L = L;
                    obj.LeftBoundaryCondition = LBC;
                    obj.RightBoundaryCondition = RBC;
                    if exist('Loads','var')
                        obj.LoadUniform = Loads.Uniform;
                        obj.LoadPoint = Loads.Point;
                    end
                case 3
                    obj.L = L;
                    obj.LeftBoundaryCondition = LBC;
                    obj.RightBoundaryCondition = RBC;
                case 2
                    obj.L = L;
                    obj.LeftBoundaryCondition = LBC;
                case 1
                    obj.L = L;
            end
            % obj.x = @(x) x;
        end
        
        function eventHandler(obj,src,evt)
            %obj.LoadUniform.b = obj.LoadUniform.a + obj.L;
            %[M, V, Y] = obj.shearMomentDeflection;
            % disp([M, V, Y]')
        end
        
        function boundaryConditions = get.BoundaryConditions(obj)
            boundaryConditions = join([obj.LeftBoundaryCondition obj.RightBoundaryCondition],"-");
        end

        function [M, V, Y] = calcShearMomentDeflection(obj)            
            inc = obj.Increment;  % beam span increment

            L = obj.L;
            W = obj.LoadUniform.W;
            F = obj.LoadPoint.F;
            a = obj.LoadPoint.a;
            b = L - a;
            % x = unique([0:inc:a, a, (a+inc):inc:L],'stable');  obj.x = x;

            E = obj.E;
            I = obj.I;

            switch lower(obj.BoundaryConditions)  % join([LBC RBC],"-")
                case "fixed-fixed"
                    [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanFF(L,W,F,a,b,E,I,inc);
                case "fixed-simple"
                    [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanFS(L,W,F,a,b,E,I,inc);
                case "simple-simple"
                    [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanSS(L,W,F,a,b,E,I,inc);
            end

            obj.x = x;
            obj.M = M;
            obj.V = dM_dx;  V = dM_dx;

            obj.Y = Y;
            obj.dY_dx = dY_dx;  %#ok<*PROP>

            obj.R1 = reactions.R1;  % R1_uniform + R1_point;
            obj.R2 = reactions.R2;  % R2_uniform + R2_point;
            obj.M1 = reactions.M1;  % M1_uniform + M1_point;
            obj.M2 = reactions.M2;  % M2_uniform + M2_point;
            % obj.x_Mmax = x_Mmax;
            % obj.x_Ymax = x_Ymax;
        end

        function [Mmax, x_Mmax, ind_Mmax] = momentMax(obj)
            [Mmax, ind_Mmax] = max(abs(obj.M),[],2);  
            s1 = size(ind_Mmax,1);  x_Mmax = zeros(s1,1);
            for m = 1:numel(ind_Mmax)
                x_Mmax(m,1) = obj.x(m,ind_Mmax(m));
            end
        end

        function [Ymax, x_Ymax] = deflectionMax(obj)
            [Ymax_abs, ind_Ymax] = max(abs(obj.Y),[],2);
            
            s1 = size(ind_Ymax,1);  Ymax = zeros(s1,1);  x_Ymax = zeros(s1,1);
            for m = 1:numel(ind_Ymax)
                Ymax(m,1) = obj.Y(m,ind_Ymax(m));
                x_Ymax(m,1) = obj.x(m,ind_Ymax(m));
            end
        end
        
        function hF = plotShearMomentDeflection(obj, m, hF)
            if ~exist('hF','var')
                hF = figure('ToolBar','none');
            end
            if ~exist('m','var')
                m = 1;
            end

            hF.Name = obj.BoundaryConditions + " Beam :: Shear-Moment-Deflection :: Case " + num2str(m);
            if any(hF.Position(3:4) < [600 800])
                hF.Position(2:4) = [get(0).ScreenSize(4)-1000 600 800];
            end
            % delete(hF.Children)
            
            x = obj.x(m,:); %#ok<*PROPLC> 
            dM_dx = obj.V(m,:);
            M = obj.M(m,:);
            Y = obj.Y(m,:);
            dY_dx = obj.dY_dx(m,:);
            [~, x_Mmax, ind_Mmax] = obj.momentMax;  Mmax = M(:,ind_Mmax);
            [Ymax, x_Ymax] = obj.deflectionMax;

            hA_Shear = subplot(4,1,1);  hA_Shear.Parent = hF;
            plot(hA_Shear,x,dM_dx)
            hA_Shear.XLabel.String = "X [in]";  hA_Shear.YLabel.String = "V [lbf]";
            hA_Shear.XLim = [0 x(end)+0.01];  hA_Shear.YLim = sign(minmax(dM_dx)).*abs(minmax(dM_dx))*1.03;

            hA_Moment = subplot(4,1,2);  hA_Moment.Parent = hF;
            hP_M = plot(hA_Moment,x,M);
            hA_Moment.XLabel.String = "X [in]";  hA_Moment.YLabel.String = "M [in*lbf]";
            hA_Moment.XLim = [0 x(end)+0.01];  hA_Moment.YLim = sign(minmax(M)).*abs(minmax(M))*1.03;
            hDt_Moment = datatip(hP_M,x_Mmax(m,1),Mmax(m,1)); %#ok<*NASGU> 

            hA_Deflection = subplot(4,1,3);  hA_Deflection.Parent = hF;
            hP_Y = plot(hA_Deflection,x,Y);
            hA_Deflection.XLabel.String = "X [in]";  hA_Deflection.YLabel.String = "Y [in]";
            hA_Deflection.XLim = [0 x(end)+0.01];  hA_Deflection.YLim = sign(minmax(Y)).*abs(minmax(Y))*1.03;
            hDt_Deflection = datatip(hP_Y,x_Ymax(m,1),Ymax(m,1));

            hA_Slope = subplot(4,1,4);  hA_Slope.Parent = hF;
            plot(hA_Slope,x,dY_dx)
            hA_Slope.XLabel.String = "X [in]";  hA_Slope.YLabel.String = "dY/dX [in/in]";
            hA_Slope.XLim = [0 x(end)+0.01];  hA_Slope.YLim = sign(minmax(dY_dx)).*abs(minmax(dY_dx))*1.03;
        end
    end

    methods (Access = private)
        function addListeners(obj)
            addlistener(obj,'L','PostSet',@obj.eventHandler);
            addlistener(obj,'LeftBoundaryCondition','PostSet',@obj.eventHandler);
            addlistener(obj,'RightBoundaryCondition','PostSet',@obj.eventHandler);
            addlistener(obj,'E','PostSet',@obj.eventHandler);
            addlistener(obj,'I','PostSet',@obj.eventHandler);
            addlistener(obj,'LoadUniform','PostSet',@obj.eventHandler);
            addlistener(obj,'LoadPoint','PostSet',@obj.eventHandler);
        end
    end
end
