classdef ImageReader
   properties
      %src: direcotry 
      %L: left camera
      %R: right camera
      %start: start number
      %N: read N succeeding images
      %left_dir; direcotry for left_camera_tensor
      %right_dir; direcotry for right_camera_tensor
      src;   
      L ;
      R ;
      start;
      N;
      left_dir;
      right_dir;   
   end
   
   
   methods
       %construction function, create instance of class ImageReader
       function obj = ImageReader(root_dir,left_cam,right_cam,start_ind,num_im)
            switch nargin
                % switch depend on number of input variables
                % 5 inputs: root_dir,left_cam,right_cam,start_ind,num_im
                
                case 5
                    obj.src = root_dir;
                        %---------------------------------           
                            if left_cam==1 || left_cam==2
                                obj.L = left_cam;
                            else
                                error('L can only be 1 or 2');
                            end
                            if right_cam==2 || right_cam==3
                                obj.R = right_cam;
                            else
                                error('R can only be 2 or 3'); 
                            end
                        %---------------------------------------        
            %                     obj.L = left_cam;
            %                     obj.R = right_cam;
                                obj.start = start_ind;
                                obj.N = num_im;
                                string1 = obj.src(end-5:end);
                                obj.left_dir = [obj.src,'/',string1,'_C',num2str(obj.L)];
                                obj.right_dir = [obj.src,'/',string1,'_C',num2str(obj.R)];
                    
                % 4 inputs: root_dir,left_cam,right_cam,num_im    
                case 4
                                    obj.src = root_dir;
                             % -------------------
                                if left_cam==1 || left_cam==2
                                    obj.L = left_cam;
                                else
                                    error('L can only be 1 or 2');
                                end
                                if right_cam==2 || right_cam==3
                                    obj.R = right_cam;
                                else
                                    error('R can only be 2 or 3'); 
                                end
                             %----------------------------
                             
                                    obj.start = 1;
                                    obj.N = start_ind;
                                    %obj.current_ind =  1;

                                    string1 = obj.src(end-5:end);
                                    obj.left_dir = [obj.src,'/',string1,'_C',num2str(obj.L)];
                                    obj.right_dir = [obj.src,'/',string1,'_C',num2str(obj.R)];   
                    
           %----------------------------------------------------------------------         
                otherwise
                             error('Initial input should be 4 or 5 parameters')
           %--------------------------------------------------------------------         
                  
           end 
       end
   end
   
%    methods
   methods
   function [left,right,loop] = next(obj)
       
       %check if the given left and right directory exist 
       if ~isfolder(obj.left_dir)
            errorMessage = sprintf('Error: The following folder does not exist:\n%s', obj.left_dir);
            uiwait(warndlg(errorMessage));
       return;
       end
       
       if ~isfolder(obj.right_dir)
            errorMessage = sprintf('Error: The following folder does not exist:\n%s', obj.right_dir);
            uiwait(warndlg(errorMessage));
       return;
       end
       
        filePattern_left = fullfile(obj.left_dir, '*.jpg');
        jpegFiles_left = dir(filePattern_left);


        filePattern_right = fullfile(obj.right_dir, '*.jpg');
        jpegFiles_right = dir(filePattern_right);
        
        %define static variable current_ind    
        global current_ind;
        if isempty(current_ind)
                current_ind=obj.start; 
        end
        
        B_left = {};
        B_right = {};
        
        if (current_ind + obj.N) >= numel(jpegFiles_left) 
                for k = current_ind: numel(jpegFiles_left)
                        F_left = fullfile(obj.left_dir,jpegFiles_left(k).name);
                        I_left = imread(F_left);
                        B_left{1,1,k-current_ind+1}=I_left;
         
                        F_right = fullfile(obj.right_dir,jpegFiles_right(k).name);
                        I_right = imread(F_right);
                        B_right{1,1,k-current_ind+1}=I_right;
                end
                left = cell2mat(B_left);
                right = cell2mat(B_right);
                
                if obj.N == 1 
                     current_ind = obj.start;
                     loop = 1;
                else
                     current_ind = current_ind+1;
                     loop = 0;
                end
                
        
        else
                for k = current_ind: current_ind+obj.N
                        F_left = fullfile(obj.left_dir,jpegFiles_left(k).name);
                        I_left = imread(F_left);
                        A_left{1,1,k-current_ind+1}=I_left;
         
                        F_right = fullfile(obj.right_dir,jpegFiles_right(k).name);
                        I_right = imread(F_right);
                        A_right{1,1,k-current_ind+1}=I_right;
         
                end
                left = cell2mat(A_left);
                right = cell2mat(A_right);
                current_ind = current_ind+1;
                loop = 0;
        end
       
       
   end
   
   end
   
end