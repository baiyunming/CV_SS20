function [result] = render(frame,mask,bg,render_mode)
  % Add function description here
  %input: frame: to be processed frame, size: 600*800*3 
  %       mask: binary mask of processed frame, size: 600*800 
  %       bg: either backgrond static image or videoreader for dynamic video background

%% if bg is Videoreader,excute follwing code
if isa(bg, 'VideoReader')
    %current_frame_index: determine which frame of the video should be the backgrond   
    persistent current_frame_index;
    if  isempty(current_frame_index)
       current_frame_index=1;
    end
    
    %justify if the video has been read out, if so set the
    %current_frame_index to 1 to the beginning of the video and read the first frame of the video
    % if not, read the current frame of the video as background image
    if current_frame_index > bg.NumberOfFrame
        current_frame_index = 1;
        bg_frame = read(bg,current_frame_index);  
    else
        bg_frame = read(bg,current_frame_index);
    end
    
    %resized the extracted background image to size(600*800*3)
    bg_resized = imresize(bg_frame,[size(frame,1),size(frame,2)]);
    
    %replace the background 
    result = repmat(mask,1,1,3) .* frame + repmat(uint8(1-mask),1,1,3) .* bg_resized;  
    
    current_frame_index=current_frame_index+1;
    
    return;
end



       

%% if bg is a image,excute follwing code
frame = uint8(frame); 
mask = uint8(mask);
bg = im2uint8(bg);           
   
%process the frame according to selected render_mode
  if strcmp(lower(render_mode) , 'foreground')
    result = repmat(mask,1,1,3) .* frame;  
    
  elseif strcmp(lower(render_mode) , 'background')
    result = repmat(uint8(1-mask),1,1,3) .* frame;
  
  elseif strcmp(lower(render_mode) , 'overlay')
    vorne  = repmat(mask,1,1,3) .* frame;
    hinten = repmat(uint8(1-mask),1,1,3) .* frame;
    vorne(:,:,1) = vorne(:,:,1) + 50*mask;
    hinten(:,:,2) = hinten(:,:,2) + 50*(uint8(1-mask));
    result = vorne + hinten;

  elseif strcmp(lower(render_mode) , 'substitute')
    bg_resized = imresize(bg,[size(frame,1), size(frame,2)]);
    result = repmat(mask,1,1,3) .* frame + repmat(uint8(1-mask),1,1,3) .* bg_resized;  
  else
      error('mode should be ''foreground'',''background'',''overlay'',''substitute'' ');
  end

  
end
