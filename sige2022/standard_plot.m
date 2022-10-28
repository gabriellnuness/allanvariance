function standard_plot(f)
% Function to let all plots with same proportion and font size 
   
    % Settings
    width = 8; % cm
    font_size = 7;
    
%     font = 'Adelle Rg'; % font too wide, overlay y axis
%     font = 'Barlow';

    % Pre-processing
    gr = (1+sqrt(5))/2;
    fig_size = [width width/gr];

    % Apply
    set(f,'Units', 'Centimeters', 'Position' , [1 1 fig_size]);
    set(f, 'PaperUnits', 'centimeters')
    set(gca, 'FontSize', font_size)
%     set(gca, 'FontName', font)
    set(f, 'PaperSize', fig_size);
    title('')
%     legend(gca,'off')

%     print(f,'fig','-dpng','-r600')
%     print(f,'fig','-depsc')
%     print(f,'fig','-dpdf','-r600')
    

end