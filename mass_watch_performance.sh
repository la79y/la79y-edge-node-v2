for i in {1..51}
do
    # Record a segment of the stream
    ffmpeg -i 'srt://164.90.241.38:10081?streamid=#!::u=bander1234,r=livestream4,m=request,t=stream,s=Session_ID' -t 10 -c copy sample${i}.ts &
done

# Wait for all ffmpeg instances to finish
wait

for i in {1..51}
do
    # Play recorded segment (Optional, based on your scenario)
    ffplay sample${i}.ts 2>&1 | tee ffplay_output_$(date +%s).log &

    # Analyze the recorded segment with ffprobe
    ffprobe -v error -show_format -show_streams sample${i}.ts > ffprobe_output_${i}.log
done

# Wait for all ffplay instances to finish, if they were used
wait