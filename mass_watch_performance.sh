# Create directories for samples and ffprobe outputs if they do not exist
mkdir -p samples
mkdir -p ffprobe_outputs

for i in {1..5}
do
    # Record a segment of the stream and store it in the samples folder
    ffmpeg -i 'srt://127.0.0.1:1235?streamid=#!::u=admin,r=test,s=12345678-1234-1234-1234-123456789abc,m=request,t=stream&passphrase=edge_pass1234&pbkeylen=16' -t 10 -c copy samples/sample${i}.ts &
done

# Wait for all ffmpeg instances to finish
wait

for i in {1..5}
do
    # Optionally, play recorded segment and log output (log files will be in the current directory)
    ffplay samples/sample${i}.ts 2>&1 | tee ffplay_output_$(date +%s).log &

    # Analyze the recorded segment with ffprobe and save the log in the ffprobe_outputs folder
    ffprobe -v error -show_format -show_streams samples/sample${i}.ts > ffprobe_outputs/ffprobe_output_${i}.log
done

# Wait for all ffplay instances to finish, if they were used
wait
