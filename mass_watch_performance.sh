# Create directories for samples and ffprobe outputs if they do not exist
mkdir -p samples
mkdir -p ffprobe_outputs

for i in {1..49}
do
    # Record a segment of the stream and store it in the samples folder
    ffmpeg -i `srt://161.35.240.212:10081?streamid=#!::u=admin${i},r=252ad23f-1eb2-476e-931a-ca9155ec00ca,s=12345678-1234-1234-1234-123456789abc,m=request,t=stream&passphrase=edge_pass1234&pbkeylen=16` -t 10 -c copy samples/sample${i}.ts &
done 

# Wait for all ffmpeg instances to finish
wait

for i in {1..49}
do
    # Optionally, play recorded segment and log output (log files will be in the current directory)
    ffplay samples/sample${i}.ts 2>&1 | tee ffplay_output_$(date +%s).log &

    # Analyze the recorded segment with ffprobe and save the log in the ffprobe_outputs folder
    ffprobe -v error -show_format -show_streams samples/sample${i}.ts > ffprobe_outputs/ffprobe_output_${i}.log
done

# Wait for all ffplay instances to finish, if they were used
wait
