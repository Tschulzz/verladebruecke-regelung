classdef Steuerung_Automatisierung < matlab.System
    % Steuerung_Automatisierung The automation procedure block for the gantry crane controller

    % Public, tunable properties
    properties
        % Sequence of boxes to pickup, numbered from left to right
        box_sequence = [1, 2, 3, 4, 5]; 

        start_time = 30;
        % 'true' if midpoints should be given to help prevent collision with other boxes along the way
        add_midpoints = true;
    end

    % Public, non-tunable properties
    properties(Nontunable)
        % Total drivable rail length, in cm
        total_rail_length = 135.8 + 118.2; 
        
        % Gripper measurements
        gripper_base_to_ground = 163;  %cm
        min_gripper_dist_to_ground = 2.5;  %cm        
        
        % A position is considered reached if ...
        % the measured position is within this many cm from the target ...
        horiz_precision = 1; 
        vert_precision = 1;
        angle_thres = 5;  % deg deviation from 180
        % and the horiz, vert, and angular speeds are under a threshold, 
        % in cm/sec and degrees/sec
        horiz_speed_thres = 1;
        vert_speed_thres = 1;
        angle_speed_thres = 15;
        
        
        baseline_to_left_switch = 4.5;  %cm
        first_box_to_baseline = 22;  %cm
        distance_between_boxes = 20;  %cm
        goal_to_last_box = 121.4;  %cm
        
        
        box_height = 11.5;  %cm
        box_width = 11;  %cm
        box_lid_width = 14;  %cm
        
        % When determining midpoints, add this height to the box_height
        add_height_to_midpoints = 3;  %cm

        % mV-per-cm factor of the horizontal absolute rotary encoder 
        horiz_abs_rot_enc_factor = 39.37; 
        % mV-per-cm factor of the vertical absolute rotary encoder 
        vert_abs_rot_enc_factor = 72.73;
    end

    properties(DiscreteState)
        % For initialization process
        time0

        % For main automation process
        box_x_pos
        box_y_pos

        goal_x_pos
        goal_y_pos

        box_nr
        magnet_on
        midpoint_reached
        horiz_setpoint
        vert_setpoint

        % For both processes
        is_positioned
        do_positioning
    end

    % Pre-computed constants
    properties(Access = private)
        
    end

    methods
        % Constructor
        function obj = Steuerung_Automatisierung(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access = protected)
        %% Common functions        
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            % For initialization process
            obj.time0 = 0;
            
            % For main automation process
            obj.box_x_pos = (obj.box_sequence - 1) * obj.distance_between_boxes ...
                + obj.first_box_to_baseline - obj.baseline_to_left_switch ...
                - obj.box_width/2;
            obj.box_y_pos = (ones(size(obj.box_x_pos)) * obj.gripper_base_to_ground) - obj.box_height + obj.min_gripper_dist_to_ground;
            
            obj.goal_x_pos = ones(size(obj.box_x_pos)) * (obj.first_box_to_baseline + 4*obj.distance_between_boxes + 121.4);
            obj.goal_y_pos = (ones(size(obj.box_x_pos)) * obj.gripper_base_to_ground) - ((1:size(obj.box_x_pos, 2)) * obj.box_height) ...
                + obj.min_gripper_dist_to_ground;
            
            obj.box_nr = 1;
            obj.magnet_on = false;
            obj.midpoint_reached = false;
            obj.horiz_setpoint = 0;
            obj.vert_setpoint = 0;
            
            % For both processes
            obj.is_positioned = false;
            obj.do_positioning = false;
        end

        function [horiz_setpoint, vert_setpoint, magnet_on, do_positioning, control_enable] = ... 
                stepImpl(obj, horiz_value, horiz_speed, vert_value, vert_speed, angle, angle_speed, ... 
                         positioning_finished, Clock)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            control_enable = Clock - obj.time0 > obj.start_time; 
            if control_enable
                if ~obj.is_positioned
                    if obj.do_positioning && positioning_finished
                        obj.is_positioned = true;
                        obj.do_positioning = false;
                    else
                        obj.do_positioning = true;
                    end
                else 
                    % Main automation part, initialization is finished! 
                    if obj.box_nr <= size(obj.box_x_pos, 2)
                        if obj.magnet_on
                            if obj.add_midpoints && ~obj.midpoint_reached
                                obj.vert_setpoint = obj.vert_abs_rot_enc_factor * (obj.box_y_pos(obj.box_nr) - (obj.box_height + obj.add_height_to_midpoints));
                            else
                                obj.horiz_setpoint = obj.horiz_abs_rot_enc_factor * obj.goal_x_pos(obj.box_nr);
                                obj.vert_setpoint = obj.vert_abs_rot_enc_factor * obj.goal_y_pos(obj.box_nr);
                            end
                        else
                            obj.horiz_setpoint = obj.horiz_abs_rot_enc_factor * obj.box_x_pos(obj.box_nr);
                            obj.vert_setpoint = obj.vert_abs_rot_enc_factor * obj.box_y_pos(obj.box_nr);
                        end

                        % Condition for reaching setpoint, values are in mV
                        if abs(obj.horiz_setpoint - horiz_value) < obj.horiz_precision * obj.horiz_abs_rot_enc_factor && ...
                                abs(obj.vert_setpoint - vert_value) < obj.vert_precision * obj.vert_abs_rot_enc_factor && ...
                                horiz_speed < obj.horiz_speed_thres * obj.horiz_abs_rot_enc_factor && ... 
                                vert_speed < obj.vert_speed_thres * obj.vert_abs_rot_enc_factor && ...
                                abs(angle) < obj.angle_thres && ...
                                angle_speed < obj.angle_speed_thres

                            if obj.magnet_on
                                if obj.add_midpoints && ~obj.midpoint_reached
                                    obj.midpoint_reached = true;
                                else
                                    % Gripper is at goal position
                                    obj.magnet_on = false;
                                    obj.midpoint_reached = false;
                                    obj.box_nr = obj.box_nr + 1;
                                end
                            else
                                % Gripper is at box
                                obj.magnet_on = true;
                            end 
                        end
                    else
                        % All boxes have been moved
                        obj.horiz_setpoint = 0;
                        obj.vert_setpoint = 0;
                        if (~obj.is_positioned)
                            if (obj.do_positioning && positioning_finished)
                                obj.is_positioned = true;
                                obj.do_positioning = false;
                            else
                                obj.do_positioning = true;
                            end
                        end
                    end
                end
            end
            
            
            do_positioning = obj.do_positioning; 
            magnet_on = obj.magnet_on;
            
            horiz_setpoint = obj.horiz_setpoint;
            vert_setpoint = obj.vert_setpoint; 
            
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            % For initialization process
        end


%         function flag = isInputSizeLockedImpl(obj,index)
%             % Return true if input size is not allowed to change while
%             % system is running
%             flag = true;
%         end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
    end

    methods(Static, Access = protected)
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename('class'));
        end

        function groups = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            % group = matlab.system.display.Section(mfilename('class'));
            groups = matlab.system.display.SectionGroup(...
              'Title','General',...
              'PropertyList',{'box_sequence', 'start_time', 'add_midpoints'});
            
            %lowerGroup = matlab.system.display.SectionGroup(...
            %  'Title','Coefficients', ...
            %  'PropertyList',{'baseline_to_left_switch'});

            %groups = [upperGroup,lowerGroup];
        end
    end
end
