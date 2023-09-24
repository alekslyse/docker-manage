#!/bin/bash

# Function to display pre-action information
display_pre_action_info() {
    local running_containers_count=$(docker ps -q | wc -l)
    echo "Number of Running Containers: $running_containers_count"
    echo "Script Mode: $mode"
    echo "Verbosity Level: $verbosity"
    echo "Retry Count: $retry_count"
    echo "Press Ctrl+C to exit or Ctrl+Z to skip retry, or press Enter/Space to continue immediately..."

    # Read a single character from the user (Enter or Space)
    read -t 5 -n 1 -s key

    if [[ "$key" == "" ]]; then
        # User pressed Enter or Space, so continue immediately
        echo ""
        return
    else
        # User pressed Ctrl+C or Ctrl+Z, so exit
        echo ""
        exit 0
    fi
}

# Function to stop and remove containers and clean up
stop_remove_and_clean() {
    echo "Stopping and removing containers..."
    docker-compose down &>/dev/null
}

# Function to change to a directory if it exists
change_to_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        cd "$dir" || return 1
        return 0
    else
        echo "Directory does not exist: $dir. Skipping..."
        return 1
    fi
}

# Initialize variables to track statistics (global scope)
containers_started=0
containers_updated=0
containers_failed=0
error_messages=""
verbosity="high"    # Default verbosity level
mode="all"          # Default mode is set to "all"
retry_count=2       # Default retry count

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -m|--mode|-mode)
            mode="$2"
            shift 2
            ;;
        -v|--verbosity|--v|--verbosity)
            verbosity="$2"
            shift 2
            ;;
        -r|--retry|--retry-count)
            retry_count="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Display pre-action information
display_pre_action_info

# Stop and remove all containers, and purge images and networks
echo "Stopping and removing all containers..."
docker stop $(docker ps -a -q) &>/dev/null
docker rm -v $(docker ps -a -q) &>/dev/null
echo "Purging dangling images..."
docker image prune -f &>/dev/null
echo "Purging unused networks (excluding those starting with 'eth')..."
docker network prune -f --filter="name=eth*" &>/dev/null

# Determine the action based on the selected mode
case "$mode" in
    all)
        echo "Finding and updating Docker containers in subdirectories..."

        # Find all subdirectories containing docker-compose.yml files
        find . -type f -name "docker-compose.yml" | while read -r file; do
            echo "Processing directory: $(dirname "$file")"

            # Change to the directory containing docker-compose.yml if it exists
            if change_to_directory "$(dirname "$file")"; then
                # Stop, remove containers, and clean up
                stop_remove_and_clean

                echo "Pulling the latest images and starting containers in $(pwd)..."

                # Attempt to start containers with retries
                retry_count_current="$retry_count"
                while [ "$retry_count_current" -gt 0 ]; do
                    echo "Retrying docker-compose start (Attempt $((retry_count - retry_count_current + 1)) of $retry_count)..."
                    if docker-compose up -d; then
                        containers_started=$((containers_started + 1))
                        containers_updated=$((containers_updated + 1))
                        break
                    else
                        containers_failed=$((containers_failed + 1))
                    fi
                    retry_count_current=$((retry_count_current - 1))
                    sleep 1
                done

                # Return to the previous directory
                cd - > /dev/null
            else
                continue
            fi
        done
        ;;
    check)
        echo "Checking running containers..."
        docker ps --format "ID: {{.ID}}\nImage: {{.Image}}\nPorts: {{.Ports}}\nNetworks: {{.Networks}}" --no-trunc
        exit 0
        ;;
    *)
        echo "Invalid mode: $mode. Valid modes are 'all' and 'check'."
        exit 1
        ;;
esac

# Calculate the time taken
end_time=$(date +%s)
duration=$((end_time - start_time))

# Display the summary based on verbosity level
echo "### Summary ###"
if [ "$verbosity" == "high" ] || [ "$verbosity" == "debug" ]; then
    echo "Containers Started: $containers_started"
    echo "Containers Updated: $containers_updated"
    echo "Containers Failed: $containers_failed"
    echo "Time Taken: $duration seconds"
    if [ -n "$error_messages" ]; then
        echo -e "\nError Messages:"
        echo "$error_messages"
    fi
elif [ "$verbosity" == "medium" ]; then
    echo "Containers Started: $containers_started"
    echo "Containers Updated: $containers_updated"
    echo "Containers Failed: $containers_failed"
    echo "Time Taken: $duration seconds"
else
    echo "Containers Started: $containers_started"
    echo "Containers Updated: $containers_updated"
    echo "Containers Failed: $containers_failed"
    echo "Time Taken: $duration seconds"
fi
echo "### End of Summary ###"

echo "All Docker containers have been stopped, removed, and updated."
