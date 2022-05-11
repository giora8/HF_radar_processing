%% plotCompHF2ADCP.m
function plotCompHF2ADCP(t_HF, U_HF, Vr_ADCP, Vtheta_ADCP, t_ADCP, z, average_every, Fs, save_video_flag)
%% Inputs
% t_HF - vector of time steps where the first step is equal to the first
% t_ADCP time step
% U_HF - [size(t_HF), 2] velocity estimations from both positive and negative
% peaks
% Vr_ADCP - [size(z) size(t_ADCP)] radial velocity from the ADCP
% Vtheta_ADCP - [size(z) size(t_ADCP)] tangential velocity from the ADCP
% t_ADCP - ADCP matlab time, first time is the same as the t_HF first cell
% z - vertical axis evaluated from the ADCP
% average_every - time averaging (minutes) for the consecutive ADCP
% measuremtnts
% Fs - sampling frequency of the ADCP
% save_video_flag - 0 - not saving, 1 - save the video
%
%% Output
% function generates a figure with ADCP profile for each time step
%

%------------------ plot entire time series from the HF ------------------%

    fig=figure; fig.Position = [10 10 1800 800];
    subplot(13, 9, 1:54);
    y_locs = max(U_HF(:, 1), U_HF(:, 2));
    U_pos = U_HF(:, 1);
    U_neg = U_HF(:, 2);
    ylim_val = ceil(max(abs(max(U_HF(:, 1))), abs(min(U_HF(:,1)))));
    scatter(t_HF, U_pos);
    hold on; scatter(t_HF, U_neg, 'x');
    hold on;
    p1 = [t_HF(1) y_locs(1) + 0.15];                     
    p2 = [t_HF(1) y_locs(1)+0.01];                         
    dp = p2-p1;
    h_q = quiver(p1(1),p1(2),dp(1),dp(2), 2, 'color', [0 0 0], 'linewidth', 2);
    ylim([-ylim_val/2, ylim_val/2]);
    xline(size(U_HF, 1)/2, 'color', [0.5 0.5 0.5], 'linewidth', 1);
    yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
    xlabel('Time [hr]'); ylabel('Velocity [m/s]');
    legend('Positive peak', 'Negative peak', 'current profile', 'box', 'off');
    xlim([1 size(U_HF, 1)]);

%-------------------- plot the first vertical profile --------------------%
    
    average_every = average_every*60; % [minutes]
    average_every_index = round(average_every * Fs);

    subplot(13, 9, [64:67 73:76 82:85 91:94 100:103 109:112] );
    plot(mean(Vr_ADCP(:, 1:average_every_index), 2), z);
    title('V_r');
    subplot(13, 9, [69:72 78:81 87:90 96:99 105:108 117:117] );
    plot(mean(Vtheta_ADCP(:, 1:average_every_index), 2), z);
    title('V_\theta');
    subplot(13, 9, 1:54);
    title(datestr(t_ADCP(1)));
    
%------------------ plot the others vertical profiles --------------------%    
    if save_video_flag == 1
        myVideo = VideoWriter('myVideoFileCentroid'); %open video file
        myVideo.FrameRate = 5;  %can adjust this, 5 - 10 works well for me
        open(myVideo)
    end
    counter = 2;
    for ii = average_every_index+1 : average_every_index : length(t_ADCP)-average_every_index

        subplot(13, 9, [64:67 73:76 82:85 91:94 100:103 109:112] );
        plot(mean(Vr_ADCP(:, ii:ii+average_every_index-1), 2), z);
        xlabel('Radial velocity [m/s]');
        ylabel('z [m]');
        title('V_r');
        yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
        xline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
        xlim([-0.55 0.55]); ylim([-35 0]);
        subplot(13, 9, [69:72 78:81 87:90 96:99 105:108 117:117] );
        plot(mean(Vtheta_ADCP(:, ii:ii+average_every_index-1), 2), z);
        xlabel('Tangential velocity [m/s]');
        title('V_\theta');
        yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
        xline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
        xlim([-0.55 0.55]); ylim([-35 0]);
        subplot(13, 9, 1:54);
        p1 = [t_HF(counter) y_locs(counter) + 0.15];                     
        p2 = [t_HF(counter) y_locs(counter)+0.01];                         
        dp = p2-p1;
        delete(h_q);
        h_q = quiver(p1(1),p1(2),dp(1),dp(2), 1, 'color', [0 0 0], 'linewidth', 2);
        title(datestr(t_ADCP(ii)));
        legend('Positive peak', 'Negative peak', '', '', 'current profile', 'box', 'off');
        pause(0.08);
        counter = counter + 1;
        
        if save_video_flag == 1
            frame = getframe(gcf); %get frame
            writeVideo(myVideo, frame);
        end
    end
    
    if save_video_flag == 1
        close(myVideo)
    end
end

