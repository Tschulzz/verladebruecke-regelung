classdef rate_limiter_classdef < matlab.System
    % Untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties

    end

    properties(DiscreteState)
        
    end

    % Pre-computed constants
    properties(Access = private)
        sample_time
        max_rate
        max_step
        difference
        new_value
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.sample_time = 0;
            obj.max_rate = 9.57;
            obj.max_step = 0;
            obj.difference = 0;
            obj.new_value = 0;
        end

        function y = stepImpl(obj,input,clock,clock_delayed,last_value,deriv)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            obj.sample_time = clock-clock_delayed;
            obj.max_step = obj.max_rate * obj.sample_time;
            
            obj.difference = input - last_value;
            if abs(obj.difference) >= obj.max_step % ist �nderung des Eingangs im Vergleich zum begrenzten Gr��e gr��er als maximale �nderung
                if (obj.difference >= 0) && (deriv >= 0)
                    obj.difference = obj.max_step;
                elseif (obj.difference >= 0) && (deriv < 0) % falls deriv negativ ist: verwende diese Steigung f�r Output
                    if abs(deriv) >= abs(obj.max_rate)
                        obj.difference = (-1) * obj.max_step;
                    else
                        obj.difference = deriv * obj.sample_time; % deriv ist negativ -> difference ist negativ
                    end
                elseif (obj.difference < 0) && (deriv < 0)
                    obj.difference = (-1) * obj.max_step;
                elseif (obj.difference < 0) && (deriv >= 0) % falls deriv positiv ist: verwende diese Steigung f�r Output
                    if abs(deriv) >= abs(obj.max_rate)
                        obj.difference = obj.max_step;
                    else
                        obj.difference = deriv * obj.sample_time; % deriv ist positiv -> difference ist positiv
                    end
                end
            end
            
            obj.new_value = obj.difference + last_value;
            y = obj.new_value;
            
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.sample_time = 0;
            obj.max_rate = 9.57;
            obj.max_step = 0;
            obj.difference = 0;
            obj.new_value = 0;
        end
    end
end
