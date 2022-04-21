from lxml import etree
import subprocess
import click
import glob
import os
import re

rootdir = os.path.dirname(os.path.abspath(__file__))
ns = {"tei": "http://www.tei-c.org/ns/1.0"}
n = 0

# https://stackoverflow.com/questions/8236107/how-to-replace-node-values-in-xml-with-python
# XPATH : target = root.xpath(".//tei:bibl", namespaces=ns)


@click.group()
def validator():
    """
    command line interface to check the validity of XML files against a relaxng schema
    and update the files with corrected data
    """


@validator.command("errlogger")
def errlogger():
    """
    function to validate xml files against XML relaxng using a rng validator CLI called 'jingtrang'
    https://pypi.org/project/jingtrang/
    :return: list of distinct rng errors
    """
    errlog = []  # list of distinct error messages
    # iterate through all matching files
    for dir in glob.iglob("*"):
        if os.path.isdir(dir) and re.match(r"[A-Z]{3}_à_corriger", dir):
            curdir = os.path.abspath(dir)  # the directory currently being scanned by the script
            for fpath in glob.iglob(f"{curdir}/*.xml"):
                # validate the file against rng schema using jingtrang in a shell subprocess
                out, err = subprocess.Popen(f"pyjing ../_schemas/odd_katabase.rng {fpath}",
                                            shell=True, encoding="utf-8", stdout=subprocess.PIPE,
                                            stderr=subprocess.PIPE).communicate()
                # build a list of errors
                try:
                    out = out.splitlines()  # store stdout (relaxng error log) as a list
                except Exception as e:
                    click.echo(f"# EXCEPTION --- {e}")
                # build a list of distinct errors
                for o in out:
                    o = str(o).replace(f"{fpath}", "")
                    o = re.sub(r"^:\d+:\d+: error: ", "", o)
                    if o not in errlog:
                        errlog.append(o)
    click.echo(errlog)
    return errlog


@validator.command("corrector")
def corrector():
    """
    function to correct XML files of New_OutputData
    :return:
    """
    # create output directories
    outclean = os.path.join(rootdir, "out_clean")  # directory to store clean files
    if not os.path.isdir(outclean):
        os.makedirs(outclean)
    outerr = os.path.join(rootdir, "out_a_corriger")  # directory to store weird files
    if not os.path.isdir(outerr):
        os.makedirs(outerr)

    # iterate through all matching files
    for dir in glob.iglob("*"):
        if os.path.isdir(dir) and re.match(r"[A-Z]{3}_à_corriger", dir):
            curdir = os.path.abspath(dir)  # the directory currently being scanned by the script
            for fpath in glob.iglob(f"{curdir}/*.xml"):  # fpath = filepath of the currently used file
                basename = os.path.basename(fpath)  # basename = name of the file without its path
                errcount = 0  # number of errors in the XML file
                # open and prepare file
                with open(fpath, mode="r") as f:
                    tree = etree.parse(f)
                    root = tree.getroot()

                    # update tei:bibl with an @ana attribute
                    bibl = root.xpath(".//tei:sourceDesc/tei:bibl", namespaces=ns)
                    bibl = bibl[0]  # an xpath returns a list => select the first and only
                                    # item of the list
                    if bibl.xpath("not(./@ana)"):
                        # get value to use for @ana from the parent directory (LAV, LAC...)
                        # and insert @ana in val
                        attr = re.sub(r"_à_corriger", r"", dir)
                        bibl.set("ana", attr)

                    # update tei:name with an @type attribute (the type of name mentionned
                    # for each catalog item) ;
                    # for each file, name returns a list of tei:name with no @type attribute
                    # context returns the tei:desc of the tei:item associated with each tei:name
                    mapping = {}  # dicitionnary matching to each name its desc
                    name = root.xpath(".//tei:item/tei:name[not(./@type)]", namespaces=ns)
                    context = root.xpath(".//tei:item[not(tei:name/@type)]/tei:desc", namespaces=ns)
                    # in this weird case (empty tei:desc or tei:name), move the files
                    # in another directory to do the cleaning by hand
                    if len(name) != len(context):
                        errcount += 1

                    # if the files are aldready clean, move them to the destination directory
                    elif len(name) == 0 and len(context) == 0:
                        errcount += 1

                    # if tei:name or tei:desc is None

                    # "normal error case" : @type is missing from tei:name, but there is
                    # a description for each missing tei:item with a missing @type
                    else:
                        # for each invalid tei:item in the file
                        for n in name:
                            # create a dictionnary mapping to each tei:name its tei:desc
                            idx = name.index(n)
                            mapping[n.text] = context[idx].text
                            # additional exception handling: if there are several invalid
                            # tei:items but in a file but one or more
                            # tei:name / tei:desc are empty
                            if n.text is not None and mapping[n.text] is not None:
                                # prompt user with name and description and ask them to add a
                                # valid @type for the tei:name
                                click.echo(basename)
                                click.echo(f"--- NAME --- \n {n.text}")
                                click.echo(f"--- DESC --- \n {mapping[n.text]}")
                                # get @type's value from user input and check its validity
                                data = click.prompt("value of tei:name's @type (author|recipient|other)")
                                if not re.match(r"^(author|recipient|other)$", data):
                                    data = click.prompt("ERROR ; value of tei:name's @type (author|recipient|other)")
                                # set attribute value
                                n.set("type", data)
                            else:
                                errcount += 1

                    # write it to the proper directory
                    if errcount != 0:
                        writer(input_xml=tree, output_dir=outerr, fname=basename)
                    else:
                        writer(input_xml=tree, output_dir=outclean, fname=basename)

                    # TO DO LATER: ADD THING TO DELETE FILES THAT HAVE BEEN WRITTEN TO
                    # OUTPUT DIRECTORIES ; CAN BE DONE IN WRITER()



def writer(input_xml, output_dir, fname):
    """
    function to write the updated xml to the proper directory
    :param input_xml: input xml, parsed with lxml and updated in corrector()
    :param output_dir: path to the directory where the file should be written
    :param fname: name of the file to be written (base name only, not the path)
    :return:
    """
    with open(f"{output_dir}/{fname}", mode="wb") as out:
        input_xml.write(out, encoding="utf-8", xml_declaration=True, pretty_print=True)





if __name__ == "__main__":
    validator()

# OUTPUT OF ERROR LOG:
"""['value of attribute "quantity" is invalid; 
        must be a string matching the regular expression "(\\-?[\\d]+/\\-?[\\d]+)", 
        must be a decimal number or must be a floating-point number', 
    'element "name" missing required attribute "type"']
"""

# À PARTIR DE LÀ :
# - parser out pour n'avoir que des données pertinentes ;
# - si out correspond à certaine erreurs répandues, imprimer les erreurs
# - ensuite, imprimer le xml correspondant
# - enfin modifier le xml avec lxml en fonction de ces erreurs
#   (si erreur: name[not(@type)] et contenu de name = truc, alors ajouter tel attrib @type
# - enregistrer les nv fichiers xml (modifiés avec lxml) dans un nv dossier 'out'
# - faire une dernière vérif avec pyjing
