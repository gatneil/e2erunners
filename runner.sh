source globals.sh

files=$(ls ${scripts_dir})
echo $files | xargs -n 1 -P ${max_dop} ./run_script.sh ${scripts_dir} ${output_dir} ${stdout_postfix} ${stderr_postfix} ${lock_dir} > ${output_dir}/${summary_file}
cat ${output_dir}/${summary_file}
if [ -f ${sendmail_config_file} ]
then
    python send_mail.py ${sendmail_config_file} ${output_dir}/${summary_file}
fi

exit 0



