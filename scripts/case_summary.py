from scripts import tse

# define function to parse case summary
def case_summary(file):
    case = tse.parser(file).parse_summary()
    case.update({'candidateID': file[5:-5]})
    return case

if __name__ == '__main__'
