classdef PropertiesBeamI < handle
    properties (SetObservable, Access = public)
        tweb = 0
        t1 = 0
        t2 = 0

        hweb = 0
        b1 = 0
        b2 = 0
        
        Area = 0
        yyMomentOfArea2
        zzMomentOfArea2
    end

    properties (Dependent)
        Iyy
        Izz
        AreaWeb
    end

    methods
        function obj = PropertiesBeamI(tweb,hweb,varargin)
            obj.tweb = tweb;
            obj.hweb = hweb;
        end

        function obj = calcProperties(obj)
            tweb = obj.tweb;  hweb = obj.hweb; %#ok<*PROP>
            t1 = obj.t1;  b1 = obj.b1;
            t2 = obj.t1;  b2 = obj.b2; 
            
            obj.Area = tweb*hweb + t1*b1 + t2*b2;
            obj.yyMomentOfArea2 = tweb*hweb^3 ...
                + ( t1*b1*((tweb + t1)/2)^2 + b1*t1^3 ) ...
                + ( t2*b2*((tweb + t2)/2)^2 + b2*t2^3 );
            obj.zzMomentOfArea2 = hweb*tweb^3 ...
                + ( t1*b1^3 ) ...
                + ( t2*b2^3 );
        end
        
        function area = get.AreaWeb(obj)
            area = obj.tweb * obj.hweb;
        end

        function Iyy = get.Iyy(obj)
            Iyy = obj.yyMomentOfArea2;
        end
        
        function Izz = get.Izz(obj)
            Izz = obj.zzMomentOfArea2;
        end
    end
end
