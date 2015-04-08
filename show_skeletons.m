%>> show_skeletons('Florence3D')
%>> show_skeletons('MSRAction3D')
%>> show_skeletons('UTKinect')

function [] = show_skeletons(dataset_name)

load ([dataset_name, '/skeletal_data'])
load ([dataset_name, '/body_model'])
J = body_model.bones;

step = 2;
plot_n_variant = 4;

if (strcmp(dataset_name, 'UTKinect') || strcmp(dataset_name, 'MSRAction3D'))

    nodes = 20;
    step = 3;

    n_actions = size(skeletal_data,1);
    n_subjects = size(skeletal_data,2);
    n_instances = size(skeletal_data,3);

    for a = 1:n_actions
        for s = 1:n_subjects
            for e = 1:n_instances
                grid off
                xlabel('x-axis')
                ylabel('y-axis')
                zlabel('z-axis')
                hold on
                motion = 0;
                if (skeletal_data_validity(a,s,e))
                    S = skeletal_data{a, s, e}.original_skeletal_data;
                    n_frames = size(S,3);
                    win_title = sprintf ('%s %d frames action %d/%d subject %d/%d instance %d/%d\n', ...
                                          dataset_name, n_frames, a, n_actions, s, n_subjects, e, n_instances);

                    for n = 1:nodes
                        variant(n) = var(S(1,n,:)) + var(S(2,n,:)) + var(S(3,n,:));
                    end
                    [Sorted,Idx] = sort(variant, 'descend');
                    Idx = Idx(1:plot_n_variant);

                    % plot each frame
                    for n = 1:n_frames
                        motion = motion + step;
                        if mod(n,step) ~= 0
                            continue
                        end
                        axis([-1.5 1.5 step (n_frames+2)*step -2 2])

                        % plot each node
                        for m = 1:nodes
                            if (1 - any(ismember(m,Idx)-1))
                                plot3(S(1,m,n), S(2,m,n) + motion, S(3,m,n), 'ro');
                            else
                                plot3(S(1,m,n), S(2,m,n) + motion, S(3,m,n), 'b');
                            end
                        end

                        % connect nodes by line
                        for j = 1:size(J,1)
                            c1 = J(j,1);
                            c2 = J(j,2);
                            line([S(1, c1, n) S(1, c2, n)], [S(2, c1, n) S(2, c2, n)]+motion, [S(3, c1, n) S(3, c2, n)], 'Color', 'b', 'LineWidth', 2);
                        end
                    end
                    fprintf(win_title)
                    title(win_title)
                end
                input('press any key to continue.')
                cla
            end
        end
    end

elseif (strcmp(dataset_name, 'Florence3D'))

    nodes = 15;

    fprintf ('Florence3D totally %d skeletal data\n', length(skeletal_data));
    for i = 1:length(skeletal_data)
        S = skeletal_data{i}.original_skeletal_data;
        n_frames = size(S,3);

        grid off
        xlabel('x-axis')
        ylabel('y-axis')
        zlabel('z-axis')
        hold on
        motion = 0;
        win_title = sprintf ('%s totally %d frames (%d/%d)\n', dataset_name, n_frames, i, length(skeletal_data));

        for n = 1:nodes
            variant(n) = var(S(1,n,:)) + var(S(2,n,:)) + var(S(3,n,:));
        end
        [Sorted,Idx] = sort(variant, 'descend');
        Idx = Idx(1:plot_n_variant);

        % plot frame by frame
        for n = 1:n_frames
            motion = motion + step;
            if mod(n,step) ~= 0
                continue
            end
            axis([-1 1 step (n_frames+2)*step -1 1]);

            % plot each node
            for m = 1:nodes
                if (1 - any(ismember(m,Idx)-1))
                    plot3(S(1,m,n), S(2,m,n) + motion, S(3,m,n), 'ro');
                else
                    plot3(S(1,m,n), S(2,m,n) + motion, S(3,m,n), 'b');
                end
            end

            % connect nodes by line
            for j = 1:size(J,1)
                c1 = J(j,1);
                c2 = J(j,2);
                line([S(1, c1, n) S(1, c2, n)], [S(2, c1, n) S(2, c2, n)] + motion, [S(3, c1, n) S(3, c2, n)], 'Color', 'b', 'LineWidth', 2);
            end
        end
        fprintf(win_title)
        title(win_title)
        input('press any key to continue.')
        cla
    end

else
    error('Unknown dataset')

end

