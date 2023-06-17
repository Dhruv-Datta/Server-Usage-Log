import psutil
import datetime


file_path = 'C:/Users/DhruvDatta/Desktop/Task Manager Log.txt'

t = datetime.datetime.now()


def get_process_info(proc):
    """Get process information as a dictionary"""
    try:
        return {
            'name': proc.name(),
            'username': proc.username(),
            'pid': proc.pid,
            'vms': proc.memory_info().vms / (1024 * 1024),
        }
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass


def get_sorted_processes_by_memory():
    """Get a list of running processes sorted by memory usage"""
    processes = [get_process_info(proc) for proc in psutil.process_iter()]
    return sorted(filter(None, processes), key=lambda proc: proc['vms'], reverse=True)


def press_enter_on_file(file_path):
    with open(file_path, 'a') as file:
        file.write('\n')


def print_in_text_file(var):
    with open(file_path, 'a') as f:
        f.write(var)


def main():
    print_in_text_file("*** Top 5 processes with highest memory usage ***")
    press_enter_on_file(file_path)

    print_in_text_file("Time and Date: {}/{}/{} at {}:{}:{}".format(t.month, t.day, t.year, t.hour, t.minute, t.second))
    press_enter_on_file(file_path)
    press_enter_on_file(file_path)

    print("Started Script")

    running_processes = get_sorted_processes_by_memory()
    for process in running_processes[:5]:
        print_in_text_file(str(process))
        press_enter_on_file(file_path)

        p = psutil.Process(process['pid'])

        print_in_text_file("{} CPU Useage: {}%".format((process['name']), p.cpu_percent(5)))
        press_enter_on_file(file_path)
        press_enter_on_file(file_path)

    cpu = psutil.cpu_percent(5)
    press_enter_on_file(file_path)
    print_in_text_file("Total CPU Usage: {}%".format(cpu))
    press_enter_on_file(file_path)

    memory = psutil.virtual_memory()[2]
    print_in_text_file("Total Memory usage: {}%".format(memory))
    press_enter_on_file(file_path)
    press_enter_on_file(file_path)
    press_enter_on_file(file_path)
    press_enter_on_file(file_path)

    print("Ended Script")
    quit()

if __name__ == '__main__':
    main()
