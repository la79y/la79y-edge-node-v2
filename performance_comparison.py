#!/usr/bin/env python3

import pandas as pd
import os
import re

# Function to check if the string is a valid float
def is_float(value):
    try:
        float(value)
        return True
    except ValueError:
        return False

# Initialize a list to hold all the data
data = []

directory = 'ffprobe_outputs/'

# Regex patterns for extracting data
resolution_pattern = re.compile(r'width=(\d+)\s+height=(\d+)')
frame_rate_pattern = re.compile(r'r_frame_rate=(\d+)/1')
sample_rate_pattern = re.compile(r'sample_rate=(\d+)')
video_start_time_pattern = re.compile(r'start_time=(\d+\.\d+)')
bit_rate_pattern = re.compile(r'bit_rate=(\d+)')
color_space_pattern = re.compile(r'color_space=([\w-]+)')
color_range_pattern = re.compile(r'color_range=([\w-]+)')

# Iterate over each file in the directory
for filename in os.listdir(directory):
    if filename.startswith('ffprobe_output') and filename.endswith('.log'):
        # Construct the full file path
        filepath = os.path.join(directory, filename)
        
        # Read the file content
        with open(filepath, 'r') as file:
            content = file.read()
            
            # Extract data using regex patterns
            resolution_match = resolution_pattern.search(content)
            frame_rate_match = frame_rate_pattern.search(content)
            sample_rate_match = sample_rate_pattern.search(content)
            video_start_time_match = video_start_time_pattern.search(content)
            bit_rate_matches = bit_rate_pattern.findall(content)
            color_space_match = color_space_pattern.search(content)
            color_range_match = color_range_pattern.search(content)
            
            # Convert and calculate necessary values
            resolution = f"{resolution_match.group(1)}x{resolution_match.group(2)}" if resolution_match else "N/A"
            frame_rate = int(frame_rate_match.group(1)) if frame_rate_match else "N/A"
            sample_rate = int(sample_rate_match.group(1)) if sample_rate_match else "N/A"
            video_start_time = float(video_start_time_match.group(1)) if video_start_time_match else "N/A"
            bit_rate_mbps = int(bit_rate_matches[1]) if len(bit_rate_matches) > 1 else (int(bit_rate_matches[0]) if bit_rate_matches else "N/A")
            color_space = color_space_match.group(1) if color_space_match else "N/A"
            color_range = color_range_match.group(1) if color_range_match else "N/A"
            
            # Append data to the list
            data.append({
                "Sample Number": filename,
                "Resolution": resolution,
                "Frame Rate (fps)": frame_rate,
                "Sample Rate (Hz)": sample_rate,
                "Video Start Time (s)": video_start_time,
                "Bit Rate (bps)": bit_rate_mbps,
                "Color Space": color_space,
                'color_range': color_range
            })

# Create DataFrame from the collected data
df = pd.DataFrame(data)

df.to_csv('stream_performance_comparison.csv', index=False)

print(df.head())  
